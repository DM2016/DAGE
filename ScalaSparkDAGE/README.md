## Distributed Annotation of Genetic Effects
### A reproducible, cloud-based annotator for the consequences (effects) of human genetic variation.

DAGE is a repository of programs written in Scala, Python, and bash that provide distributed genetic variant effect annotation operations using Apache Spark and a cloud-hosted, user-instantiated or user-reinstanted (using AMI images for reproducibility) Cassandra cluster which hosts a database of variant effects (VEPDB).

> IMPORTANT!
> DAGE is designed for AWS cloud services and requires the user to have to an AWS account.  All costs will be billed to the user, not to anybody else!
> Always keep your AWS account information private!

## Method:

DAGE reads data from S3 cloud storage in VCF format and builds a resilient distributed dataset (RDD), an abstraction provided by Apache Spark for distributed computation.  Methods for querying a Cassandra database containing variant effect annotations are provided by the spark-cassandra-connector, which exposes a Cassandra database to Spark as if it were an RDD.  These Spark-to-Cassandra queries utilize a 4-part compound key that uniquely identifies a genetic variant:

*chromosome    position    reference_allele    alternative_allele*

And the effects of the alternative allele for that genetic variant are returned and appended to the RDD that holds genetic variants. Output is then written in compressed VCF format.

## BUILD

Build automation is provided via the spsubmit bash shell script.  spsubmit uses sbt (Scala build tools) to build a fat jar, which is then passed to spark-submit for execution.
