import java.text.DecimalFormat

import com.datastax.spark.connector._
import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

/**
  * Created by dichenli on 2/28/16.
  */
object Main {

  def main(args: Array[String]) {

    val conf = new SparkConf(true).setAppName("VCF VEP annotation")
      .set("spark.cassandra.connection.host", "127.0.0.1")
    val sc = new SparkContext(conf)  //spark context

    //VCF file as RDD
    val protocol = "file://"
    val dataDir = "/Users/dichenli/Documents/TPOT_project/VCF_VEP/"
    val inputFile = sc.textFile(protocol + dataDir +
      "vcf").cache()

    //cassandra DB as a RDD
    val vepDB = sc.cassandraTable("vep_1kgp", "vep_annotation")
      .map(row => (row.get[String]("key"), row.get[String]("value")))

    //add more metadata to header
    val vepMetaHeader = sc.parallelize(VEPMetaData.metadata)

    val output = Annotation.annotate(inputFile, vepDB, vepMetaHeader)

    val outputDir = protocol + dataDir + "spark_results"
    output.saveAsTextFile(outputDir)

  }

}

// TODO how to deal with header and body with multiple input files? Are they the same?
// Note: total running time: 2.5min, 2min are spent on Cassandra query. half of time is spent on sorting