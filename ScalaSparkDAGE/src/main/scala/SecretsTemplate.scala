/**
  * Created by dichenli on 3/9/16.
  * The Secrets.scala file is hidden in git because it contains confidential keys
  * This file demonstrates what the real Secrets.scala looks like
  */
object SecretsTemplate {
  val aws_credentials_profile = "REPLACE_WITH_REAL_VALUE"
  val aws_access_key_id = "REPLACE_WITH_REAL_VALUE"
  val aws_secret_access_key = "REPLACE_WITH_REAL_VALUE"

  val input_file_path = "s3n://bucket/folder/input/filename.vcf"
  val output_dir_path = "s3n://bucket/folder/output"

  val cassandra_connection_host = "111.111.111.111"
}
