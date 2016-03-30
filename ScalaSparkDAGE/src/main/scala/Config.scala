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
                    keySpace: String = "vep_1kgp",
                    tableName: String = "vep_annotation",
                    sort: Boolean = false //if a sort of vep.vcf is conducted
                  )

