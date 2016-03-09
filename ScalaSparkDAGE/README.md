A scala spark script to convert VCF to VEP file. It currently hard-coded data file location, but should be easy to refactor it so that it connects to any data source.

To build and run, invoke ./spsubmit. Basically it uses sbt to build a fat jar, then submit it to spark-submit to execute.