/**
  * Created by dichenli on 3/28/16.
  */

import VCFMetaHeader._
import org.apache.spark.rdd.RDD

import scala.util.matching.Regex

/**
  * Created by dichenli on 3/28/16.
  */
object Annotation {

  implicit class RDDOps[T](rdd: RDD[T]) {
    /**
      * Split one RDD to two by a filter function.
      * [[http://stackoverflow.com/questions/29547185/apache-spark-rdd-filter-into-two-rdds code snippet referenced]]
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
    * a line of data in VCF file, either annotated or not
    */
  abstract class VCFLine {
    def toVCFString: String
    val position: Long
  }

  /**
    * A line of data in VCF file that's not yet annotated, it has 8 fixed columns (chrom, pos, id...)
    * and any number of genotypes data from the study
    * @param chrom chrom#
    * @param pos position
    * @param id id
    * @param ref_alt ref and alt fields
    * @param qual_filter quality and filter fields
    * @param info info field
    * @param format_genotypes format column and all genotypes data from the study
    */
  case class RawVCFLine(chrom: String, pos: String, id: String, ref_alt: String,
                        qual_filter: String, info: String, format_genotypes: String) extends VCFLine {
    val annotationKey = chrom + "_" + pos + "_" + ref_alt.replace('\t', '_')
    override val position = pos.toLong
    override def toVCFString = Array(chrom, pos, id, ref_alt, qual_filter, info, format_genotypes).mkString("\t")
  }

  /**
    * a line of data in VCF file that's already annotated
    * @param rawVCFLine the original line
    * @param annotation the annotation string to apply to VCF line
    */
  case class VepVCFLine(rawVCFLine: RawVCFLine, annotation: String) extends VCFLine {
    override val position = rawVCFLine.pos.toLong
    override def toVCFString = Array(rawVCFLine.chrom, rawVCFLine.pos, rawVCFLine.id,
      rawVCFLine.ref_alt, rawVCFLine.qual_filter, rawVCFLine.info + ";" + annotation.trim,
      rawVCFLine.format_genotypes).mkString("\t")
  }

  /**
    * parse VCF line by regex to extract fields from raw string
    * @param line a VCF data line in original string form
    * @param vcfLineRegex provided, the regex to parse the VCF line
    * @return parsed line of [[RawVCFLine]] class
    */
  def parseVcfLine(line: String,
                   vcfLineRegex:Regex = """^(.+?)\t(.+?)\t(.+?)\t(.+?\t.+?)\t(.+?\t.+?)\t(.+?)\t(.+)$""".r
                  ): RawVCFLine = line match {
    case vcfLineRegex(chrom, pos, id, ref_alt, qual_filter, info, format_genotypes) =>
      RawVCFLine(chrom, pos, id, ref_alt, qual_filter, info, format_genotypes)
  }

  /**
    * deal with cases where annotation is available or not
    * @param line a raw vcf line
    * @param annotation annotation string, or empty if it doesn't exist in DB
    * @return RDD of the [[VCFLine]] lines annotated or not
    */
  def matchVepVcfLine(line: RawVCFLine, annotation: Option[String]): VCFLine = annotation match {
    case None => line //cassandra query miss. Do nothing
    // How to initiate Ensembl VEP query?
    case Some(str) => VepVCFLine(line, str)
  }

  /**
    * Annotate VCF file
    * @param dbQuery a function to get all annotations data of the vcf lines from a DB
    * @param vcf RDD of raw VCF file
    * @param vepMetaHeader the metadata lines (## lines) about VEP to be inserted
    * @param sort if true, keep the original order of VCF file
    * @return (vepVcf, miss). vepVcf: vcf lines with vep annotation. miss: keys not found in DB
    */
  def annotate(dbQuery: RDD[RawVCFLine] => RDD[(String, String)])
              (vcf: RDD[String], vepMetaHeader: RDD[String],
               sort: Boolean): (RDD[String], RDD[String]) = {

    //separate header and body
    val (metaHeader, body) = vcf.splitBy(_.startsWith("#"))

    //process header
    val processedMetaHeader = processMetaAndHeader(metaHeader, vepMetaHeader)

    //parse body, query annotations
    val vcfLines = body.map(parseVcfLine(_))
    val vepKV = dbQuery(vcfLines)

    //annotate each VCF line by VepDB
    var annotated: RDD[(String, (RawVCFLine, Option[String]))] =
      vcfLines.map(vcfLine => (vcfLine.annotationKey, vcfLine)).leftOuterJoin(vepKV)
    if (sort) {
      annotated = annotated.sortBy {
        case (key, (rawVCFLine, annotation)) => rawVCFLine.position
      }
    }

    //convert VCFLine lines to string form
    val vepBody = annotated.map {
      case (key, (rawVCFLine, annotation)) => matchVepVcfLine(rawVCFLine, annotation)
    }.map(_.toVCFString)
    //extract all lines that are not being annotated because of DB query miss
    val miss = annotated.filter {
      case (key, (rawVCFLine, annotation)) => annotation.isEmpty
    }.keys //keys missing in vepDB

    //prepend meta and header info to each partition
    val vepVcf = vepBody.mapPartitions(partition => Iterator(processedMetaHeader) ++ partition)
    (vepVcf, miss) //return
  }

}
