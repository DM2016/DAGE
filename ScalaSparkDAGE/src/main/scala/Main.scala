import Annotation._
import com.datastax.spark.connector._
import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}
import java.util.Calendar
import java.util.Date

/**
  * Created by dichenli on 2/28/16.
  * DAGE: distributed annotation of genetic effects
  */
object Main {

  /**
    * parse command line arguments by scopt
    * https://github.com/scopt/scopt
    */
  val parser = new scopt.OptionParser[Config]("scopt") {
    head("dage", "0.0.1")
    note("DAGE: Distributed Annotation of Genetic Effects\n")

    opt[String]('i', "input") required() action { (x, c) =>
      c.copy(input = x) } text "Required, specify the path to input vcf file or directory"

    opt[String]('o', "output") required() action { (x, c) =>
      c.copy(output = x) } text "Required, specify the path for output vep annotated files"

    opt[String]("aws-access-key-id") optional() action { case (x, c) =>
      c.copy(AWSAccessKeyID = x)} text("Optional, but required for AWS S3 access, " +
        "specify the awsAccessKeyId")

    opt[String]("aws-secret-access-key") optional() action { case (x, c) =>
      c.copy(AWSAccessKey = x)} text("Optional, but required for AWS S3 access, " +
      "specify the awsSecretAccessKey")

    opt[String]('h', "host") required() action { (x, c) =>
      c.copy(host = x) } text "Required, specify the comma-separated host IP addresses for cassandra DB"

    opt[String]('p', "port") optional() action { (x, c) =>
      c.copy(port = x) } text "Optional, specify the port number for cassandra DB. Default: 9042"

    opt[Unit]('s', "sort") optional() action { (_, c) =>
      c.copy(sort = true) } text "Optional flag to sort vep.vcf file by position number. Default: false"

    opt[Unit]("filter-lof-hc") optional() action { (_, c) =>
      c.copy(filterHighConfidence = true) } text "Optional flag to filter data with only " +
      "HC (high confident) loss of function"

    opt[String]("export-missing-keys") optional() action { (x, c) =>
      c.copy(missingKeysS3Dir = x) } text "Optional flag to export keys missing from VepDB to specified directory "

    help("help") text "prints this usage text"
  }


  //TODO check to make sure all the directories provided exist before proceed

  def initSpark(jobConfig: Config): Unit = {
    val sparkConf = new SparkConf(true).setAppName("DAGE VCF VEP annotation")
      .set("spark.cassandra.connection.host", jobConfig.host)
    if (jobConfig.port != null) {
      sparkConf.set("spark.cassandra.connection.port", jobConfig.port)
    }
    val sc = new SparkContext(sparkConf)  //spark context
    if (jobConfig.AWSAccessKeyID != null && jobConfig.AWSAccessKey != null) {
      sc.hadoopConfiguration.set("fs.s3.impl", "org.apache.hadoop.fs.s3native.NativeS3FileSystem")
      sc.hadoopConfiguration.set("fs.s3n.awsAccessKeyId", jobConfig.AWSAccessKeyID)
      sc.hadoopConfiguration.set("fs.s3n.awsSecretAccessKey", jobConfig.AWSAccessKey)
    }

    val inputRDD = sc.textFile(jobConfig.input).cache()
    val vepMetaHeader = sc.parallelize(VEPMetaData.metadata)

    val (output, miss) = annotate(inputRDD, vepMetaHeader, jobConfig)
    output.saveAsTextFile(jobConfig.output)

    if (jobConfig.missingKeysS3Dir != null) {
      miss.saveAsTextFile(jobConfig.missingKeysS3Dir + new Date().getTime)
    }
  }

  def main(args: Array[String]) {
    parser.parse(args, Config()) map { config =>
      initSpark(config)
    } getOrElse {
      // arguments are bad, usage message will be displayed
      print("Invalid configuration")
    }
  }

}