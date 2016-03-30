import java.text.DecimalFormat

import com.datastax.spark.connector._
import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

/**
  * Created by dichenli on 2/28/16.
  */
object MainRemote {

  def main(args: Array[String]) {
    println("start")
    val conf = new SparkConf(true).setAppName("VCF VEP annotation")
      .set("spark.cassandra.connection.host", "52.91.205.242")
    val sc = new SparkContext(conf)  //spark context
    sc.hadoopConfiguration.set("fs.s3n.awsAccessKeyId", Secrets.aws_access_key_id)
    sc.hadoopConfiguration.set("fs.s3n.awsSecretAccessKey", Secrets.aws_secret_access_key)

    val inputFile = sc.textFile(Secrets.input_file_path).cache()

    //cassandra DB as a RDD
    val vepDB = sc.cassandraTable("vep_1kgp", "vep_annotation")
      .map(row => (row.get[String]("key"), row.get[String]("value")))

    //add more metadata to header
    val vepMetaHeader = sc.parallelize(VEPMetaData.metadata)

    val output = Annotation.annotate(inputFile, vepDB, vepMetaHeader)

    output.saveAsTextFile(Secrets.output_dir_path)
  }

}

// TODO how to deal with header and body with multiple input files? Are they the same?
// TODO make a private github repo
// Note: total running time: 2.5min, 2min are spent on Cassandra query