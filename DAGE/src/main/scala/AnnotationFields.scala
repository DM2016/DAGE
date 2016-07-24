import com.datastax.spark.connector.UDTValue

/**
  * Created by dichenli on 5/8/16.
  * To represent the vep_annotation data structure pulled from Cassandra VepDB
  *
  * The schema of the VepDB is:
  * (chrom:int, pos:bigint, ref:text, alt:text, annotations: List<frozen<vep_annotation>>)
  * where vep_annotation is a user-defined data type in Cassandra with the following fields:
  * (vep: text, lof: text, lof_filter: text, lof_flags: text, lof_info: text, other_plugins: text)
  * The partition key is (chrom, pos, ref, alt).
  *
  * @param cassandraUDTValue [[UDTValue]] defined by SparkCassandraConnector. Here it represents the
  *                          (vep, lof, lof_filter, lof_flags, lof_info, other_plugins) data structure in Cassandra
  */
case class AnnotationFields(cassandraUDTValue: UDTValue) {
  val vep = cassandraUDTValue.get[String]("vep")
  val lof = cassandraUDTValue.get[String]("lof")
  val lof_filter = cassandraUDTValue.get[String]("lof_filter")
  val lof_flags = cassandraUDTValue.get[String]("lof_flags")
  val lof_info = cassandraUDTValue.get[String]("lof_info")
  val other_plugins = cassandraUDTValue.get[String]("other_plugins")

  /**
    * @return the annotation string that will be shown on VEP annotated VCF file
    */
  override def toString: String = {
    "%s%s|%s|%s|%s%s".format(vep, lof, lof_filter, lof_flags, lof_info, other_plugins)
  }

  /**
    * @return if this annotation field has high confidence (HC) in the lof_filter field
    */
  def isHighConfidenceLof: Boolean = lof_filter.equals("HC")
}

/*
 * some code examples of interacting with Spark-Cassandra-Connector and UDTValue class (for future coding reference):
 *  val row: CassandraRow = sc.cassandraTable(jobConfig.keySpace, jobConfig.tableName).first
 *  println(row)
 *  println(row.get[String]("ref")) //prints the ref column
 *  val a: List[UDTValue] = row.get[List[UDTValue]]("annotations")
 *  println(a.head) //prints the first UDTValue representing the "vep_annotation" user defined type
 *  println(a.head.get[String]("vep"))
 */