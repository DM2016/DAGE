/* SimpleApp.scala */
import org.apache.spark.SparkContext
import org.apache.spark.SparkConf
import com.datastax.spark.connector._

object CassandraDemo {

  def main(args: Array[String]) {
    val conf = new SparkConf(true).setAppName("Main Application")
        .set("spark.cassandra.connection.host", "127.0.0.1")
    val sc = new SparkContext(conf)

    //save data to cassandra
    val collection = sc.parallelize(Seq(("key3", 3), ("key4", 4)))
    collection.saveToCassandra("test", "kv", SomeColumns("key", "value"))
    //query cassandra
    val rdd = sc.cassandraTable("test", "kv")
    println(rdd.count)
    println(rdd.first)
    println(rdd.map(_.getInt("value")).sum)
  }

}