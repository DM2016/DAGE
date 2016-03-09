A scala spark script to convert VCF to VEP file. It currently hard-codes data file location, but it should be easy to refactor it so that it can connect to any data source.

To build and run, invoke "spsubmit" bash script. Basically it uses sbt to build a fat jar, then submit it to spark-submit to execute.