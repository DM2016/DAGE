DAGE is a series of programs written in Scala that provide distributed genetic variant effect annotation operations using Apache Spark.

## Distributed Annotation of Genetic Effects

DAGE reads data in VCF format and builds a resilient distributed dataset (RDD), an abstraction provided by Apache Spark for distributed computation.  Methods for querying a Cassandra database containing variant effect annotations are provided by the spark-cassandra-connector.  These queries utilize a unique key that represents a genetic variant:

*chromosome position reference_allele alternative_allele*

And the effects of the alternative allele for that genetic variant are returned and appended to the RDD that holds genetic variants. Output is then written in compressed VCF format.

## BUILD

Build automation is provided via the spsubmit bash shell script.  spsubmit uses sbt (Scala build tools) to build a fat jar, which is then passed to spark-submit for execution.
