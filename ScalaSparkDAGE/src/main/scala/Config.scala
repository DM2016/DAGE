import java.util.Date

/**
  * Created by dichenli on 3/30/16.
  */
case class Config(
                   input: String = null, //input vcf files path, could be a .vcf file or a directory of vcf files
                   output: String = null,
                   AWSAccessKeyID: String = null,
                   AWSAccessKey: String = null,
                   host: String = null, //cassandra host
                   port: String = null, //cassandra port
                   keySpace: String = "dage",
                   tableName: String = "vep_db",
                   jobName: String = new Date().getTime.toString,
                   sort: Boolean = false, //if true, keep the original order of VCF file by an expensive sort operation
                   filterHighConfidence: Boolean = false,
                   missingKeysS3Dir: String = null,
                   flipStrand: Boolean = true,
                   flipAllele: Boolean = true,
                   partitions: Option[Int] = Option.empty
                 )

