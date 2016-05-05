/**
  * Created by dichenli on 3/28/16.
  */

import VCFMetaHeader._
import com.datastax.spark.connector._
import com.datastax.spark.connector.rdd.CassandraJoinRDD
import org.apache.spark.rdd.RDD

import scala.util.matching.Regex

/**
  * Created by dichenli on 3/28/16.
  *
  * Query the Cassandra DB (VepDB) and annotate the VCF file.
  */
object Annotation {

  implicit class RDDOps[T](rdd: RDD[T]) {
    /**
      * Split one RDD to two by a filter function.
      * http://stackoverflow.com/questions/29547185/apache-spark-rdd-filter-into-two-rdds code snippet referenced
      *
      * @param f a filter function
      * @return two RDDs, with data that pass and fail the filter
      */
    def splitBy(f: T => Boolean): (RDD[T], RDD[T]) = {
      //I can't find a way to split one RDD to two in a single run, so this is a bit inefficient
      val passes = rdd.filter(f)
      val fails = rdd.filter(e => !f(e)) // Spark doesn't have filterNot
      (passes, fails)
    }
  }

  /**
    * The key to the VepDB.
    *
    * The schema of the VepDB is:
    * (chrom:int, pos:bigint, ref:text, alt:text, annotations: List<frozen<vep_annotation>>)
    * where vep_annotation is a user-defined data type in Cassandra with the following fields:
    * (vep: text, lof: text, lof_filter: text, lof_flags: text, lof_info: text, other_plugins: text)
    *
    * The partition key is (chrom, pos, ref, alt). Here it is represented by [[VepKey]]
    * The List of annotation fields is represented by [[AnnotationFields]]
    *
    * @param chrom chrom#
    * @param pos   position
    * @param ref   ref field
    * @param alt   alt field
    */
  case class VepKey(chrom: Int, pos: Long, ref: String, alt: String) {
    override def toString: String = {
      "%d\t%d\t%s\t%s".format(chrom, pos, ref, alt)
    }
  }

  /**
    * To represent the vep_annotation data structure pulled from Cassandra VepDB
    *
    * @param cassandraUDTValue [[UDTValue]] defined by SparkCassandraConnector. Here it represents the
    *                          (vep, lof, lof_filter, lof_flags, lof_info, other_plugins) data structure in Cassandra
    */
  case class AnnotationFields(cassandraUDTValue: UDTValue) {
    val vep = cassandraUDTValue.get[String]("vep")
    val lof = cassandraUDTValue.get[String]("lof")
    val lof_filter = cassandraUDTValue.get[String]("lof_filter")
    val lof_flags = cassandraUDTValue.get[String]("lof_flags")
    val lof_info = cassandraUDTValue.get[String]("lof_info")
    val other_plugins = cassandraUDTValue.get[String]("other_plugins")

    /**
      * @return the annotation string that will be shown on VEP annotated VCF file
      */
    override def toString: String = {
      "%s%s|%s|%s|%s%s".format(vep, lof, lof_filter, lof_flags, lof_info, other_plugins)
    }

    //TODO it should be lof_filter equals HC, but the sample data has different order
    /**
      * @return if this annotation field has high confidence (HC) in the lof_filter field
      */
    def isHighConfidence: Boolean = lof_info.equals("HC")
  }


  /**
    * a line of data in VCF file, either annotated or not
    */
  abstract class VCFLine {
    /**
      * VepDB key, to query from the DB
      */
    val vepKey: VepKey

    /**
      * @return the string representation of the [[vepKey]]
      */
    def extractKeyString: String = vepKey.toString

    /**
      * @return the position field in VCF file
      */
    def position: Long = vepKey.pos

    /**
      * @return The string to represent a valid line in the VCF file
      */
    def toVCFString: String

    /**
      * @return if the line has high confident loss of function, judged by lof_filter field
      */
    def isHighConfidence: Boolean
  }

  /**
    * A line of data in VCF file that's not yet annotated, it has 8 fixed columns (chrom, pos, id...)
    * and any number of genotypes data from the study
    *
    * @param chrom            chrom#
    * @param pos              position
    * @param id               id
    * @param ref              ref field
    * @param alt              alt field
    * @param qual_filter      quality and filter fields
    * @param info             info field
    * @param format_genotypes format column and all genotypes data from the study
    */
  case class RawVCFLine(chrom: String, pos: String, id: String, ref: String, alt: String,
                        qual_filter: String, info: String, format_genotypes: String) extends VCFLine {

    override val vepKey = VepKey(chrom.toInt, pos.toLong, ref, alt)

    override def toVCFString = Array(chrom, pos, id, ref, alt, qual_filter, info, format_genotypes).mkString("\t")

    override def isHighConfidence = false
  }

  /**
    * a line of data in VCF file that's already annotated
    *
    * @param rawVCFLine          the original line
    * @param annotationsUDTValue the list of annotations directly pulled from VepDB.
    *                            [[UDTValue]] is defined by SparkCassandraConnector. Here it represents the
    *                            (vep, lof, lof_filter, lof_flags, lof_info, other_plugins)
    *                            data structure in Cassandra
    */
  case class VepVCFLine(rawVCFLine: RawVCFLine, annotationsUDTValue: List[UDTValue]) extends VCFLine {

    override val vepKey = rawVCFLine.vepKey
    override val position = rawVCFLine.pos.toLong
    val annotations: List[AnnotationFields] = annotationsUDTValue.map(AnnotationFields)

    /**
      * Insert VEP annotations to the original VCF line
      *
      * @return The string to represent a valid line in the VCF file
      */
    override def toVCFString = Array(rawVCFLine.chrom, rawVCFLine.pos, rawVCFLine.id,
      rawVCFLine.ref, rawVCFLine.alt, rawVCFLine.qual_filter,
      rawVCFLine.info + ";" + annotations.mkString(","),
      rawVCFLine.format_genotypes).mkString("\t")

    override def isHighConfidence = annotations.exists(_.isHighConfidence)
  }

  /**
    * parse VCF line by regex to extract fields from raw string
    *
    * @param line         a VCF data line in original string form
    * @param vcfLineRegex provided, the regex to parse the VCF line
    * @return parsed line of [[RawVCFLine]] class
    */
  def parseVcfLine(line: String,
                   vcfLineRegex: Regex = "^(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?\t.+?)\t(.+?)\t(.+)$".r
                  ): RawVCFLine = line match {
    case vcfLineRegex(chrom, pos, id, ref, alt, qual_filter, info, format_genotypes) =>
      RawVCFLine(chrom, pos, id, ref, alt, qual_filter, info, format_genotypes)
  }

  /**
    * deal with cases where annotation is available or not
    *
    * @param line        a raw vcf line
    * @param annotations the optional list of annotations directly pulled from VepDB.
    *                    [[UDTValue]] is defined by SparkCassandraConnector. Here it represents the
    *                    (vep, lof, lof_filter, lof_flags, lof_info, other_plugins)
    *                    data structure in Cassandra.
    *                    If it's None, it means the VepDB doesn't contain the record
    * @return RDD of the [[VCFLine]] lines annotated or not
    */
  def matchVepVcfLine(line: RawVCFLine, annotations: Option[List[UDTValue]]): VCFLine = annotations match {
    case None => line //cassandra query miss. Do nothing
    // How to initiate Ensembl VEP query?
    case Some(udtValues) => VepVCFLine(line, udtValues)
  }

  /**
    * Annotate VCF file
    *
    * @param vcf           RDD of raw VCF file
    * @param vepMetaHeader the metadata lines (## lines) about VEP to be inserted
    * @param jobConfig     the configuration values of job
    * @return (vepVcf, miss). vepVcf: vcf lines with vep annotation. miss: keys not found in DB
    */
  def annotate(vcf: RDD[String], vepMetaHeader: RDD[String],
               jobConfig: Config): (RDD[String], RDD[String]) = {

    //separate header and body
    val (metaHeader, body) = vcf.splitBy(_.startsWith("#"))

    //process header
    val processedMetaHeader = processMetaAndHeader(metaHeader, vepMetaHeader)

    //parse body, query annotations
    val vcfLines: RDD[RawVCFLine] = body.map(parseVcfLine(_))

    //Extract all keys that we need to use to query VepDB
    val queryKeys: RDD[VepKey] = vcfLines.map(_.vepKey)
    /*
     * Query DB
     * About joinWithCassandraTable: see https://goo.gl/CMfmLq
     * I choose not to repartition before joining because now every node holds 100% of data.
     * But we may need to change the code for efficiency if the DB expands.
     * Also we may specify which columns to get (we only need "annotations") to save network traffic
     */
    val queriedDBRows: CassandraJoinRDD[VepKey, CassandraRow] =
      queryKeys.joinWithCassandraTable(jobConfig.keySpace, jobConfig.tableName)
    // extract only the annotations column of the DB
    val queriedAnnotations: RDD[(VepKey, List[UDTValue])] = queriedDBRows.map {
      case (vepKey: VepKey, cassandraRow: CassandraRow) =>
        (vepKey, cassandraRow.get[List[UDTValue]]("annotations"))
    } //.distinct()
    //Calling distinct() is necessary if the input VCF file has duplicate lines, otherwise with RDD join operation,
    //for N identical lines, there will be N^2 identical lines produced in the output file.
    //However, distinct() is expensive, so I choose to not add it here and assume input VCF never has duplicates


    //annotate each VCF line by VepDB, convert data to our self-defined data structures
    var annotated: RDD[VCFLine] =
      vcfLines.map(vcfLine => (vcfLine.vepKey, vcfLine)).leftOuterJoin(queriedAnnotations).map {
        case (key: VepKey, (rawVCFLine: RawVCFLine, annotations: Option[List[UDTValue]])) =>
          matchVepVcfLine(rawVCFLine, annotations)
      }

    if (jobConfig.sort) {
      //Sort by position
      annotated = annotated.sortBy {
        case vcfLine => vcfLine.position
      }
    }

    /*
     * extract all lines that are not being annotated because of DB query miss, return a string
     * with format: "chromosome    position    ref    alt" (separated by '\t')
     */
    val miss = annotated.filter {
      case vcfLine: RawVCFLine => true
      case vcfLine: VepVCFLine => false
    }.map(_.extractKeyString)

    //filter lines with high lof confidence
    if (jobConfig.filterHighConfidence) {
      annotated = annotated.filter(_.isHighConfidence)
    }

    //Convert to RDD of body lines of VEP VCF file
    val vepVcfBody: RDD[String] = annotated.map(_.toVCFString)
    //prepend meta and header info to each partition
    val vepVcf = vepVcfBody.mapPartitions(partition => Iterator(processedMetaHeader) ++ partition)
    (vepVcf, miss) //return
  }

}


/*
 * some examples of vepDB_v2 data to scala data structure conversion (just for future reference):
 *  val row: CassandraRow = sc.cassandraTable(jobConfig.keySpace, jobConfig.tableName).first
 *  println(row)
 *  println(row.get[String]("ref")) //prints the ref column
 *  val a: List[UDTValue] = row.get[List[UDTValue]]("annotations")
 *  println(a.head) //prints the first UDTValue representing the "vep_annotation" user defined type
 *  println(a.head.get[String]("vep"))
 */