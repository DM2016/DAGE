import java.text.DecimalFormat
import AnnotationHelper.RDDOps
import VCFMetaHeader._
import AnnotationHelper._
import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkContext, SparkConf}

/**
  * Created by dichenli on 3/26/16.
  * The same spark job, but use plain text file RDD as vepDB instead of a Cassandra DB
  */
object MainNoCassandra {

  def annotate(vcf: RDD[String], vepKV: RDD[(String, String)],
               vepMetaHeader: RDD[String], jobConfig: Config): (RDD[String], RDD[String]) = {

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
    if (queried.getNumPartitions > 10) {
      queried = queried.coalesce(10, shuffle = false)
    }
    val vepBody = queried.map(pair => matchVepVcfLine(pair._2._1, pair._2._2)).map(_.toVCFString)
    val miss = queried.filter(pair => pair._2._2.isEmpty).keys //keys not seen in vepDB

    //prepend meta and header info to each partition
    val vepVcf = vepBody.mapPartitions(partition => Iterator(processedMetaHeader) ++ partition)
    (vepVcf, miss) //return
  }

  def main(args: Array[String]) {

    val conf = new SparkConf(true).setAppName("VCF VEP annotation")
    val sc = new SparkContext(conf)  //spark context

    val protocol = "file://"
    val dataDir = "/Users/dichenli/Documents/TPOT_project/VCF_VEP/"
    val inputFile = sc.textFile(protocol + dataDir +
      "first_ten_thousand_lines_of_1kGP_chr1.vcf").cache()

    //cassandra DB as a RDD
    val vepDB = sc.textFile("file:///Users/dichenli/Downloads/1kGP_variants_VEP_LOFTEE_key_value_pairs.tsv.gz")
      .map(_.split('\t')).map(line => (line(0) + "_" + line(1) + "_" + line(2) + "_" + line(3), line(4)))

    //add more metadata to header
    val vepMetaHeader = sc.parallelize(VEPMetaData.metadata)

    val (output, miss) = annotate(inputFile, vepDB, vepMetaHeader, Config())

    val outputDir = protocol + dataDir + "spark_results"
    output.saveAsTextFile(outputDir)

  }
}
