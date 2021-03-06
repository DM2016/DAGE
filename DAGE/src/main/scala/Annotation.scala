/**
  * Created by dichenli on 3/28/16.
  */

import VCFLineTypes._
import VCFMetaHeader._
import com.datastax.spark.connector._
import com.datastax.spark.connector.rdd.CassandraJoinRDD
import org.apache.spark.SparkContext
import org.apache.spark.rdd.RDD

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

  private def queryHelper(annotated: RDD[VepVCFLine], unannotated: RDD[RawVCFLine],
                  transformFunctions: List[RawVCFLine => RawVCFLine], jobConfig: Config)
  : (RDD[VepVCFLine], RDD[RawVCFLine]) = transformFunctions match {
    case Nil => (annotated, unannotated)
    case flipFunction :: otherFunctions =>
      // Scala API: http://goo.gl/LbvQF4
      // A leftOuterJoin would be very helpful but it's not yet implemented, see https://goo.gl/WJ59MS
      val queried: CassandraJoinRDD[RawVCFLine, CassandraRow] = unannotated.map(flipFunction)
        .joinWithCassandraTable(jobConfig.keySpace, jobConfig.tableName)
      val missed: RDD[RawVCFLine] = unannotated.subtract(queried.map {
        case (rawVCFLine, cassandraRow) => rawVCFLine.reference match {
          case Some(refLine) => refLine
          case None => rawVCFLine
        }
      })
      val vepVcfLines = queried.map {
        case (rawVCFLine, cassandraRow) => VepVCFLine(rawVCFLine, cassandraRow.get[List[UDTValue]]("annotations"))
      }
      queryHelper(annotated ++ vepVcfLines, missed, otherFunctions, jobConfig)
  }

  /**
    * Try to annotate the raw VCF lines by VepDB query.
    * Try each of the transform functions in a sequence to convert the original VCF line
    * to different forms if the previous form fails to find an annotation in DB. The functions are applied in the order
    * specified by the transformFunctions list.
    *
    * @param rawVCFLines RDD of un-annotaed VCF lines
    * @param transformFunctions a list of functions to transform each RawVCFLine to another.
    * @param jobConfig The global job config object
    * @param sc spark context
    * @return a pair of annotated VCF lines and unannotated VCF lines
    */
  private def query(rawVCFLines: RDD[RawVCFLine], transformFunctions: List[RawVCFLine => RawVCFLine],
            jobConfig: Config, sc: SparkContext): (RDD[VepVCFLine], RDD[RawVCFLine]) =
    queryHelper(sc.emptyRDD, rawVCFLines, transformFunctions, jobConfig)


  private def getFlipFunctions(jobConfig: Config): List[RawVCFLine => RawVCFLine] = {
    var flipFunctions = List((line: RawVCFLine) => line)
    if (jobConfig.flipStrand) {
      flipFunctions = flipFunctions :+ ((line: RawVCFLine) => line.strandFlippedVCFLine)
    }
    if (jobConfig.flipAllele) {
      flipFunctions = flipFunctions :+ ((line: RawVCFLine) => line.alleleFlippedVCFLine)
    }
    if (jobConfig.flipStrand && jobConfig.flipAllele) {
      flipFunctions = flipFunctions :+ ((line: RawVCFLine) => line.strandAlleleFlippedVCFLine)
    }
    flipFunctions
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
               jobConfig: Config, sc: SparkContext): (RDD[String], RDD[String]) = {

    //separate header and body
    val (metaHeader, body) = vcf.splitBy(_.startsWith("#"))

    //process header
    val processedMetaHeader = processMetaAndHeader(metaHeader, vepMetaHeader)

    //parse body
    val optionalVcfLines: RDD[Option[RawVCFLine]] = body.map(parseVcfLine(_))
    val vcfLines: RDD[RawVCFLine] = optionalVcfLines.filter(_.isDefined).map(_.get)

    val (annotated: RDD[VepVCFLine], unannotated: RDD[RawVCFLine]) =
      query(vcfLines, getFlipFunctions(jobConfig), jobConfig, sc)

    var vcfLinesAfterAnnotation = annotated.asInstanceOf[RDD[VCFLine]]
    //filter lines with high lof confidence
    if (jobConfig.filterHighConfidence) {
      vcfLinesAfterAnnotation = vcfLinesAfterAnnotation.filter(_.isHighConfidenceLof)
    } else {
      vcfLinesAfterAnnotation = vcfLinesAfterAnnotation ++ unannotated.asInstanceOf[RDD[VCFLine]]
    }
    if (jobConfig.sort) {
      vcfLinesAfterAnnotation = vcfLinesAfterAnnotation.sortBy(vcfLine => vcfLine.position)
    }

    //After annotation, convert lines back to String format
    var vepVcfBody: RDD[String] = vcfLinesAfterAnnotation.map(_.toVCFString)
    var miss = unannotated.map(_.toVCFString)

    if (jobConfig.partitions.isDefined) {
      val partitions = jobConfig.partitions.get
      vepVcfBody = vepVcfBody.coalesce(numPartitions = partitions, shuffle = false)
      miss = miss.coalesce(numPartitions = partitions, shuffle = false)
    }

    //prepend meta and header info to each partition
    //avoid adding header to empty partition
    val vepVcf = vepVcfBody.mapPartitions {
      case partition: Iterator[String] =>
        if (partition.isEmpty) {
          Iterator.empty
        } else {
          Iterator(processedMetaHeader) ++ partition
        }
    }

    /*
     * extract all lines that are not being annotated because of DB query miss, return a string
     * with format: "chromosome    position    ref    alt" (separated by '\t')
     */
    (vepVcf, miss) //return
  }

}

