/**
  * Created by dichenli on 3/28/16.
  */
import org.apache.spark.rdd.RDD

/**
  * Created by dichenli on 3/28/16.
  */
object Utils {

  // Split one RDD to two by a filter function. code snippet copied from
  // http://stackoverflow.com/questions/29547185/apache-spark-rdd-filter-into-two-rdds
  implicit class RDDOps[T](rdd: RDD[T]) {
    def partitionBy(f: T => Boolean): (RDD[T], RDD[T]) = {
      val passes = rdd.filter(f)
      val fails = rdd.filter(e => !f(e)) // Spark doesn't have filterNot
      (passes, fails)
    }
  }

}
