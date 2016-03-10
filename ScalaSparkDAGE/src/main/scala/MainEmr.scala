import java.text.DecimalFormat

import com.datastax.spark.connector._
import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

/**
  * Created by dichenli on 2/28/16.
  */
object MainEmr {

  def main(args: Array[String]) {
    println("start")
    val conf = new SparkConf(true).setAppName("VCF VEP annotation")
      .set("spark.cassandra.connection.host", "54.175.83.232")
    val sc = new SparkContext(conf)  //spark context
    sc.hadoopConfiguration.set("fs.s3n.awsAccessKeyId", Secrets.aws_access_key_id)
    sc.hadoopConfiguration.set("fs.s3n.awsSecretAccessKey", Secrets.aws_secret_access_key)

    println("conf done")
    val inputFile = sc.textFile(Secrets.input_file_path).cache()
    println("read input done")
    // Split one RDD to two by a filter function. code snippet copied from
    // http://stackoverflow.com/questions/29547185/apache-spark-rdd-filter-into-two-rdds
    implicit class RDDOps[T](rdd: RDD[T]) {
      def partitionBy(f: T => Boolean): (RDD[T], RDD[T]) = {
        val passes = rdd.filter(f)
        val fails = rdd.filter(e => !f(e)) // Spark doesn't have filterNot
        (passes, fails)
      }
    }
    val (header, body) = inputFile.partitionBy(_.startsWith("#"))


    //process header
    val columnTitles = header.filter(!_.startsWith("##"))
    val columnTitleStr = columnTitles.first()
    val meta = header.filter(_ != columnTitleStr)
    //add more metadata to header
    val VEPMetaHeader = sc.parallelize(VEPMetaData.metadata)
    val vepHeader = (meta ++ VEPMetaHeader ++ columnTitles)
      .coalesce(numPartitions = 1, shuffle = false)


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

    val vcf = body.map(_.split('\t')).map(
      line => VCFLine(line(0).toInt, line(1).toLong,
        line(2), line(3), line(4), line(5).toDouble,
        line(6), line(7), line.drop(8))
    )

    println("start read cassandra")
    //cassandra DB as a RDD
    val vepDB = sc.cassandraTable("vep_1kgp", "vep_annotation")
      .map(row => (row.get[String]("key"), row.get[String]("value")))
    println("read cassandra done")

    //query cassandra database
    def extractKey(line:VCFLine) = line.chrom.toString + '_' + line.pos.toString + '_' +
      line.ref + '_' +  line.alt.toString
    val queried = vcf.map(vcfLine => (extractKey(vcfLine), vcfLine)).leftOuterJoin(vepDB)
    //after query, deal with hit and miss separately
    def processQueriedData(line:VCFLine, annotation:Option[String]) = annotation match {
      case None => line //cassandra query miss. Do nothing for now.
      // How to initiate Ensembl VEP query?
      case Some(str) => VCFLine(line.chrom, line.pos, line.id, line.ref, line.alt, line.qual,
        line.filter, line.info + ";" + str.trim, line.genotypes)
    }
    val vepBody = queried.map(pair => processQueriedData(pair._2._1, pair._2._2))
      .sortBy(_.pos).map(_.toVCFString)

    val output = vepHeader ++ vepBody

    println("start open output")
    output.saveAsTextFile(Secrets.output_dir_path)
    println("all done")
  }

}

// TODO how to deal with header and body with multiple input files? Are they the same?
// TODO make a private github repo
// Note: total running time: 2.5min, 2min are spent on Cassandra query