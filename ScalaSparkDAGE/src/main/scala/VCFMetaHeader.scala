import org.apache.spark.rdd.RDD
import Utils._

/**
  * Created by dichenli on 3/28/16.
  */
object VCFMetaHeader {

//  //partition metadata lines by their prefixes
//  private def partitionHeaders(headers: RDD[String], prefix: Seq[String]): Seq[RDD[String]] = prefix match {
//    case str +: rest =>
//      val (filtered, failed) = headers.partitionBy(_.startsWith(str))
//      filtered +: partitionHeaders(failed, rest)
//    case Seq() => Seq(headers)
//  }
//
//  //partition metadata lines by types, remove duplicates, sorted, then merge to one partition
//  private def mergeMetaLines(meta: RDD[String]):RDD[String] =
//    partitionHeaders(meta.coalesce(1, shuffle = false), Seq(
//      "##fileformat",
//      "##fileDate",
//      "##assembly",
//      "##reference",
//      "##source",
//      "##contig",
//      "##pedigreeDB",
//      "##phasing",
//      "##ALT",
//      "##FORMAT",
//      "##INFO",
//      "##FILTER",
//      "##SAMPLE"
//    )).map(rdd => rdd.distinct().map((_, null)).sortByKey().keys).reduce(_++_)
//
//  def processMetaAndHeader(metaHeader: RDD[String], vepMeta: RDD[String]): String = {
//    val (meta, header) = metaHeader.partitionBy(_.startsWith("##"))
//
//    //add more metadata to header
//        (mergeMetaLines(meta) ++ vepMeta ++ header.distinct())
//          .coalesce(numPartitions = 1, shuffle = false)
//  }

  def processMetaAndHeader(metaHeader: RDD[String], vepMeta: RDD[String]): String = {
    val (meta, header) = metaHeader.partitionBy(_.startsWith("##"))

    //take distinct lines of metadata while preserving the order
    val distinctMeta = meta.zipWithIndex().groupByKey()
      .map(kv => (kv._2.min, kv._1)).sortByKey().values

//    (distinctMeta ++ vepMeta ++ header.distinct()).saveAsTextFile("/Users/dichenli/Downloads/distinctMeta")

    //add more metadata to header
    (distinctMeta ++ vepMeta ++ header.distinct()).coalesce(1, shuffle = false).reduce(_+"\n"+_)
  }
}
