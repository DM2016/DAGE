/**
  * Created by dichenli on 2/28/16.
  */
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.SparkConf

object WordCount {

  def main(args: Array[String]) {
    val conf = new SparkConf(true)
    val sc = new SparkContext(conf)

    //word count
    val logFile = "/Users/dichenli/Documents/TPOT_project/" +
      "tryScalaSpark/src/main/resources/word_count_sample.txt"
    val logData = sc.textFile(logFile, 2).cache()
    val numAs = logData.filter(line => line.contains("a")).count()
    val numBs = logData.filter(line => line.contains("b")).count()
    println("Lines with a: %s, Lines with b: %s".format(numAs, numBs))
  }

}
