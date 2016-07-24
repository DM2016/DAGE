import org.apache.spark.rdd.RDD
import Annotation._

/**
  * Created by dichenli on 3/28/16.
  */
object VCFMetaHeader {

  /**
    * insert VEP annotation meta data to the original VCF metadata and header lines
    * @param metaHeader metadata and header lines (starting with '#' or '##') of vcf file
    * @param vepMeta metadata lines for VEP annotation
    * @return VCF header with VEP metadata lines in one giant string that contains multiple lines
    */
  def processMetaAndHeader(metaHeader: RDD[String], vepMeta: RDD[String]): String = {
    val (meta, header) = metaHeader.splitBy(_.startsWith("##"))

    //take distinct lines of metadata while preserving the order
    val distinctMeta = meta.zipWithIndex().groupByKey()
      .map(kv => (kv._2.min, kv._1)).sortByKey().values

    //add more metadata to header
    (distinctMeta ++ vepMeta ++ header.distinct())
      .coalesce(1, shuffle = false).reduce(_+"\n"+_)
  }
}
