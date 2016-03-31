import java.text.DecimalFormat

import org.apache.spark.SparkContext
import org.apache.spark.rdd.RDD
import Utils.RDDOps
import VCFMetaHeader._

/**
  * Created by dichenli on 3/27/16.
  */
object Annotation {

  abstract class VCFLine {
    def toVCFString: String
    val position: Long
  }

  case class RawVCFLine(chrom: String, pos: String, id: String, ref_alt: String,
                     qual_filter: String, info: String, format_genotypes: String) extends VCFLine {
    val annotationKey = chrom + "_" + pos + "_" + ref_alt.replace('\t', '_')
    override val position = pos.toLong
    override def toVCFString = Array(chrom, pos, id, ref_alt, qual_filter, info, format_genotypes).mkString("\t")
  }

  case class VepVCFLine(rawVCFLine: RawVCFLine, annotation: String) extends VCFLine {
    override val position = rawVCFLine.pos.toLong
    override def toVCFString = Array(rawVCFLine.chrom, rawVCFLine.pos, rawVCFLine.id,
      rawVCFLine.ref_alt, rawVCFLine.qual_filter, rawVCFLine.info + ";" + annotation.trim,
      rawVCFLine.format_genotypes).mkString("\t")
  }

  val vcfLineRegex = """^(.+?)\t(.+?)\t(.+?)\t(.+?\t.+?)\t(.+?\t.+?)\t(.+?)\t(.+)$""".r
  def parseVcfLine(line: String): RawVCFLine = line match {
    case vcfLineRegex(chrom, pos, id, ref_alt, qual_filter, info, format_genotypes) =>
      RawVCFLine(chrom, pos, id, ref_alt, qual_filter, info, format_genotypes)
  }

  def matchVepVcfLine(line: RawVCFLine, annotation: Option[String]): VCFLine = annotation match {
    case None => line //cassandra query miss. Do nothing
    // How to initiate Ensembl VEP query?
    case Some(str) => VepVCFLine(line, str)
  }

  def annotate(vcf: RDD[String], vepKV: RDD[(String, String)],
               vepMetaHeader: RDD[String], jobConfig: Config): RDD[String] = {

    //separate header and body
    val (metaHeader, body) = vcf.partitionBy(_.startsWith("#"))

    //process header
    val processedMetaHeader = processMetaAndHeader(metaHeader, vepMetaHeader)

    //annotate each VCF line by VepDB
    var queried: RDD[(String, (RawVCFLine, Option[String]))] =
      body.map(parseVcfLine).map(vcfLine => (vcfLine.annotationKey, vcfLine)).leftOuterJoin(vepKV)
    if (jobConfig.sort) {
      queried = queried.sortBy(_._2._1.position)
    }
    val vepBody = queried.map(pair => matchVepVcfLine(pair._2._1, pair._2._2)).map(_.toVCFString)

    //prepend meta and header info to each partition
    vepBody.mapPartitions(partition => Iterator(processedMetaHeader) ++ partition)
  }

}
