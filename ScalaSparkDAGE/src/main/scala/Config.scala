/**
  * Created by dichenli on 3/30/16.
  */
case class Config (
                    input: String = null, //input vcf files path, could be a .vcf file or a directory of vcf files
                    output: String = null,
                    AWSAccessKeyID: String = null,
                    AWSAccessKey: String = null,
                    host: String = null, //cassandra host
                    port: String = null, //cassandra port
                    keySpace: String = "vep_space",
                    tableName: String = "vep_db",
                    sort: Boolean = false, //if true, keep the original order of VCF file by an expensive sort operation
                    missingKeysS3Dir:String = "s3://dage-spark-data/miss/"
                  )

