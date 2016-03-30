import java.text.DecimalFormat

import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkContext, SparkConf}

/**
  * Created by dichenli on 3/26/16.
  * The same spark job, but use plain text file RDD as vepDB instead of a Cassandra DB
  */
object MainNoCassandra {

  def main(args: Array[String]) {

    val conf = new SparkConf(true).setAppName("VCF VEP annotation")
    val sc = new SparkContext(conf)  //spark context

    val protocol = "file://"
    val dataDir = "/Users/dichenli/Documents/TPOT_project/VCF_VEP/"
    val inputFile = sc.textFile(protocol + dataDir +
      "first_ten_thousand_lines_of_1kGP_chr1.vcf").cache()

    //cassandra DB as a RDD
    val vepDB = sc.textFile(protocol + dataDir +
      "key_value_pairs").map(_.split('\t')).map(line => (line(0) + "_" + line(1) + "_" + line(2) + "_" + line(3), line(4)))

    //add more metadata to header
    val vepMetaHeader = sc.parallelize(VEPMetaData.metadata)

    val output = Annotation.annotate(inputFile, vepDB, vepMetaHeader)

    val outputDir = protocol + dataDir + "spark_results"
    output.saveAsTextFile(outputDir)

  }
}
