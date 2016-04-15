import org.apache.spark.rdd.RDD
import Annotation._

/**
  * Created by dichenli on 3/28/16.
  */
object VCFMetaHeader {

  def processMetaAndHeader(metaHeader: RDD[String], vepMeta: RDD[String]): String = {
    val (meta, header) = metaHeader.partitionBy(_.startsWith("##"))

    //take distinct lines of metadata while preserving the order
    val distinctMeta = meta.zipWithIndex().groupByKey()
      .map(kv => (kv._2.min, kv._1)).sortByKey().values

    //add more metadata to header
    (distinctMeta ++ vepMeta ++ header.distinct())
      .coalesce(1, shuffle = false).reduce(_+"\n"+_)
  }
}
