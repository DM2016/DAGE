/**
  * Created by dichenli on 3/28/16.
  */
import org.apache.spark.rdd.RDD

/**
  * Created by dichenli on 3/28/16.
  */
object AnnotationHelper {

  // Split one RDD to two by a filter function. code snippet copied from
  // http://stackoverflow.com/questions/29547185/apache-spark-rdd-filter-into-two-rdds
  implicit class RDDOps[T](rdd: RDD[T]) {
    def partitionBy(f: T => Boolean): (RDD[T], RDD[T]) = {
      val passes = rdd.filter(f)
      val fails = rdd.filter(e => !f(e)) // Spark doesn't have filterNot
      (passes, fails)
    }
  }


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

}
