import Annotation._
import com.datastax.driver.core.ConsistencyLevel
import org.apache.spark.{SparkConf, SparkContext}

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

    opt[Int]("partitions") optional() action { (x, c) =>
      c.copy(partitions = Some(x)) } text "Optional parameter to specify the number of partitions" +
      " in the final output of a job. The repartition step may be slow, especially if the number of partitions " +
      "is too small. Also, if a partition is too large for an worker, the job will fail by OutOfMemoryException."

    opt[Int]("parallelism") optional() action { (x, c) =>
      c.copy(parallelism = Some(x)) } text "Optional parameter to specify the spark.default.parallelism value"

    opt[String]("name") optional() action { (x, c) =>
      c.copy(jobName = x + c.jobName) } text "Specify a name for the job"

    opt[Unit]("flip-strand") optional() action { (_, c) =>
      c.copy(flipStrand = true) } text "Try to match DB by flipping strand"

    opt[Unit]("flip-allele") optional() action { (_, c) =>
      c.copy(flipAllele = true) } text "Try to match DB by flipping allele (ref and alt columns)"

    help("help") text "prints this usage text"
  }

  def runSpark(jobConfig: Config): Unit = {
    val sparkConf = new SparkConf(true).setAppName("DAGE VCF VEP annotation")
      .set("spark.cassandra.connection.host", jobConfig.host)
      // about consistency levels: https://goo.gl/nzu9JW, https://goo.gl/gn16lK
      // With LOCAL_ONE, Cassandra client will contact only one node responsible for the data in current data center,
      // Because the DB is never updated, there won't be any inconsistency issue
      .set("spark.cassandra.output.consistency.level", ConsistencyLevel.LOCAL_ONE.toString)

    if (jobConfig.port != null) {
      sparkConf.set("spark.cassandra.connection.port", jobConfig.port)
    }

    if (jobConfig.parallelism.isDefined) {
      sparkConf.set("spark.default.parallelism", jobConfig.parallelism.get.toString)
    }

    val sc: SparkContext = new SparkContext(sparkConf)  //spark context

    if (jobConfig.AWSAccessKeyID != null && jobConfig.AWSAccessKey != null) {
      sc.hadoopConfiguration.set("fs.s3n.awsAccessKeyId", jobConfig.AWSAccessKeyID)
      sc.hadoopConfiguration.set("fs.s3n.awsSecretAccessKey", jobConfig.AWSAccessKey)
    }

    val inputRDD = sc.textFile(jobConfig.input).cache()
    val vepMetaHeader = sc.parallelize(VEPMetaData.metadata)

    val (output, miss) = annotate(inputRDD, vepMetaHeader, jobConfig, sc)
    output.saveAsTextFile(jobConfig.output + jobConfig.jobName)

//    println("Missing keys count: " + miss.count())
//    println(miss.collect().mkString("\n"))
    if (jobConfig.missingKeysS3Dir != null) {
      miss.saveAsTextFile(jobConfig.missingKeysS3Dir + jobConfig.jobName)
    }
  }

  def main(args: Array[String]) {
    parser.parse(args, Config()) map { config =>
      runSpark(config)
    } getOrElse {
      // arguments are bad, usage message will be displayed
      print("Invalid configuration")
    }
  }

}

//TODO update documentation
//TODO refactor code for efficiency and good structure
//TODO mark all lines that are matched after flip strand or allele


//TODO use a more professional way to document and track TODO lists
//TODO allow user to decide if they want to match strand and allele flipped annotation
//TODO add info to indicate if the annotation is done from strand/allele flipping
//TODO check to make sure all the directories in arguments exist before proceed to real job
//TODO a cheap way to avoid empty partitions
//TODO allow user to specify number of partitions in the final output
//TODO allow user to decide if they want to output all missed keys (it defaults to yes now)
//TODO allow user to access S3 by an AWS profile rather than key pair (is it even possible?)
//TODO write unit test and/or integration test
//TODO in class Config, change all fields that could be null to Option[Type]