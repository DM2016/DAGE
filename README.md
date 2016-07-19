# Distributed Annotation of Genetic Effects
## Dichen Li, Brian S. Cole PhD, and Jason H. Moore PhD FACMI
### The Institute for Biomedical Informatics, University of Pennsylvania Perelman School of Medicine, Philadelphia, PA

![License](https://img.shields.io/badge/license-GPLv3-blue.svg)

Dage is a cloud-based distributed effect annotator for known human genetic variants aimed at reproducibility, scalability, flexibility, and cost-efficiency.  Dage defines fast and cost-efficient annotation of genetic variants by integrating Apache Spark with a distributed Cassandra database containing cached variant effects (VEPDB).

This repository is divided into three components: ScalaSparkDAGE contains the Scala and Spark code for performing distributed annotation of human genetic variants read from AWS S3 storage, PySparkCassandra contains Python and CQL code to populate a Cassandra database with precomputed genetic variant effect annotations (e.g. from VEP, hence "VEPDB"), and DageBoot contains an automated Cassandra cluster launching utility.

> Note: DageBoot is also available from PyPI via "pip install dageboot".

> Also note: the programs utilize AWS cloud services.  For this reason, AWS account credentials are required.

Distributed computation offers diverse benefits for computational genetics tasks, including variant effect annotation.  By leveraging a distributed database of precomputed effect annotations for human genetic variants, we demonstrate fast and cost-effective annotation of genetic variant effects, a crucial component of the analysis of the effects of polymorphisms observed in genetic studies that focus on pathways, netwoks, and cellular components.

