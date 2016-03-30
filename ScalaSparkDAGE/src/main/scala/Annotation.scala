import java.text.DecimalFormat

import org.apache.spark.rdd.RDD
import Utils.RDDOps
import VCFMetaHeader._

/**
  * Created by dichenli on 3/27/16.
  */
object Annotation {

  // By VCF protocol (http://samtools.github.io/hts-specs/VCFv4.1.pdf),
  // the first 8 columns are fixed. So we can structure a VCF data line
  // to the following object
  case class VCFLine(chrom: Int, pos: Long, id: String, ref: String,
                     alt: String, qual: Double, filter: String,
                     info: String, genotypes: Array[String]) {

    val formatter = new DecimalFormat("#.###")
    def toVCFString = (
      Array(chrom.toString, pos.toString, id, ref, alt,
        formatter.format(qual).toString, filter, info) ++ genotypes
      ).mkString("\t")
  }//TODO Array and mkString is slow. There is too many useless work following split("\t"), we only need three splits


  def annotate(vcf: RDD[String], vepKV: RDD[(String, String)], vepMetaHeader: RDD[String]): RDD[String] = {
    val (metaHeader, body) = vcf.partitionBy(_.startsWith("#"))
    //process header
    val processedMetaHeader = processMetaAndHeader(metaHeader, vepMetaHeader)


    val vcfBody = body.map(_.split('\t')).map(
      line => VCFLine(line(0).toInt, line(1).toLong,
        line(2), line(3), line(4), line(5).toDouble,
        line(6), line(7), line.drop(8))
    )

    //query cassandra database
    def extractKey(line:VCFLine) = line.chrom.toString + '_' + line.pos.toString + '_' +
      line.ref + '_' +  line.alt.toString
    val queried = vcfBody.map(vcfLine => (extractKey(vcfLine), vcfLine)).leftOuterJoin(vepKV)
    //after query, deal with hit and miss separately
    def processQueriedData(line:VCFLine, annotation:Option[String]) = annotation match {
      case None => line //cassandra query miss. Do nothing for now.
      // How to initiate Ensembl VEP query?
      case Some(str) => VCFLine(line.chrom, line.pos, line.id, line.ref, line.alt, line.qual,
        line.filter, line.info + ";" + str.trim, line.genotypes)
    }
    val vepBody = queried.map(pair => processQueriedData(pair._2._1, pair._2._2))
//            .sortBy(_.pos)
      .map(_.toVCFString)

//    processedMetaHeader ++ vepBody
    //prepend meta and header info to each partition
    vepBody.mapPartitions(iter => Iterator(processedMetaHeader) ++ iter)
  }


}
