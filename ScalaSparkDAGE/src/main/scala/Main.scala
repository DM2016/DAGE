import AnnotationHelper._
import VCFMetaHeader._
import com.datastax.spark.connector._
import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

/**
  * Created by dichenli on 2/28/16.
  * DAGE: distributed annotation of genetic effects
  */
object Main {

  val parser = new scopt.OptionParser[Config]("scopt") {
    head("dage", "0.0.1")
    note("DAGE: Distributed Annotation of Genetic Effects\n")

    opt[String]('i', "input") required() action { (x, c) =>
      c.copy(input = x) } text("Required, specify the path to input vcf file or directory")

    opt[String]('o', "output") required() action { (x, c) =>
      c.copy(output = x) } text("Required, specify the path for output vep annotated files")

    opt[String]("awsKeyId") optional() action { case (x, c) =>
      c.copy(AWSAccessKeyID = x)} text("Optional, but required for AWS S3 access, " +
        "specify the awsAccessKeyId")

    opt[String]("awsKey") optional() action { case (x, c) =>
      c.copy(AWSAccessKey = x)} text("Optional, but required for AWS S3 access, " +
      "specify the awsSecretAccessKey")

    opt[String]('h', "host") required() action { (x, c) =>
      c.copy(host = x) } text("Required, specify the comma-separated host IP addresses for cassandra DB")

    opt[String]('p', "port") optional() action { (x, c) =>
      c.copy(port = x) } text("Optional, specify the port number for cassandra DB. Default: 9042")

    opt[Unit]('s', "sort") optional() action { (x, c) =>
      c.copy(sort = true) } text("Optional flag to sort vep.vcf file by position number. Default: false")

    help("help") text("prints this usage text")
  }

  case class VepKey(key: String)

  def annotate(vcf: RDD[String], vepMetaHeader: RDD[String],
               jobConfig: Config): (RDD[String], RDD[String]) = {

    //separate header and body
    val (metaHeader, body) = vcf.partitionBy(_.startsWith("#"))

    //process header
    val processedMetaHeader = processMetaAndHeader(metaHeader, vepMetaHeader)

    val vcfLines = body.map(parseVcfLine)
    //https://github.com/datastax/spark-cassandra-connector/blob/master/doc/2_loading.md#join-with-a-generic-rdd-after-repartitioning
    //I choose not to repartition before joining because now every node holds 100% of data.
    //But we may need to change the code if the DB expands.
    val vepKV = vcfLines.map(vcfLine => VepKey(vcfLine.annotationKey))
      .joinWithCassandraTable(jobConfig.keySpace, jobConfig.tableName)
      .map {case (vepKey, cassandraRow) => (vepKey.key, cassandraRow.get[String]("value"))}

    //annotate each VCF line by VepDB
    var queried: RDD[(String, (RawVCFLine, Option[String]))] =
      vcfLines.map(vcfLine => (vcfLine.annotationKey, vcfLine)).leftOuterJoin(vepKV)
    if (jobConfig.sort) {
      queried = queried.sortBy(_._2._1.position)
    }
//    if (queried.getNumPartitions > 10) {
//      queried = queried.coalesce(10, shuffle = false)
//    }
    val vepBody = queried.map(pair => matchVepVcfLine(pair._2._1, pair._2._2)).map(_.toVCFString)
    val miss = queried.filter(pair => pair._2._2.isEmpty).keys //keys not seen in vepDB

    //prepend meta and header info to each partition
    val vepVcf = vepBody.mapPartitions(partition => Iterator(processedMetaHeader) ++ partition)
    (vepVcf, miss) //return
  }

  def initSpark(jobConfig: Config): Unit = {
    val sparkConf = new SparkConf(true).setAppName("DAGE VCF VEP annotation")
      .set("spark.cassandra.connection.host", jobConfig.host)
    if (jobConfig.port != null) {
      sparkConf.set("spark.cassandra.connection.port", jobConfig.port)
    }
    val sc = new SparkContext(sparkConf)  //spark context
    if (jobConfig.AWSAccessKeyID != null && jobConfig.AWSAccessKey != null) {
      sc.hadoopConfiguration.set("fs.s3n.awsAccessKeyId", jobConfig.AWSAccessKeyID)
      sc.hadoopConfiguration.set("fs.s3n.awsSecretAccessKey", jobConfig.AWSAccessKey)
    }

    val inputRDD = sc.textFile(jobConfig.input).cache()
    val vepMetaHeader = sc.parallelize(VEPMetaData.metadata)

    val (output, miss) = annotate(inputRDD, vepMetaHeader, jobConfig)
    output.saveAsTextFile(jobConfig.output)
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