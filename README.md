# Distributed Annotation of Genetic Effects
 Dichen Li, Brian S. Cole, Jason H. Moore

The Institute for Biomedical Informatics, University of Pennsylvania Perelman School of Medicine, Philadelphia, PA

Dage is a cloud-based distributed effect annotator for known human genetic variants.  Dage defines fast and cost-efficient annotation of genetic variants by integrating Apache Spark with a distributed Cassandra database containing cached variant effects.

We demonstrate the compilation of a dataset of genetic variant effects, VEPDB, which was instantiated from all genetic variants observed in the 1000 Genomes Project phase 3 version 5.  Genetic variants were annotated using ENSEMBL's Variant Effect Predictor.  The 1000 Genomes Project data represents a diverse sample of deeply genotyped humans and furthermore is frequently utilized for the imputation of genetic variants during genome-wide association studies (GWAS).  VEPDB therefore provides precomputed genetic variant effect annotations for genetic variants likely to be encountered during modern genetic studies.

Distributed computation offers diverse benefits for computational genetics tasks, including variant effect annotation.  By leveraging a distributed database of precomputed effect annotations for human genetic variants, we demonstrate fast and cost-effective annotation of genetic variant effects, a crucial component of the analysis of the effects of polymorphisms observed in genetic studies on pathways, netwoks, and cellular components.


###Table 
See ScalaSparkDAGE for scala related code, and PySparkCassandra for python related code.  DageBoot is an automated cluster launching utility which requires AWS account credentials.
