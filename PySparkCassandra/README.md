This directory contains Python source to populate a Cassandra database with genetic variant effect annotations.  The resulting database is then available for distributed access, e.g. by a Spark cluster such as DAGE.

populate_vep_cassandra.py: python script to populate cassandra database with sample data

NOTE: this populator currently only supports GZIP-compressed input data.  The format of the input data is 5-column digest extracted from VEP output VCF files: chrom, pos, ref, alt, and INFO.  The INFO field is parsed by functions within the Python source code.  Note that VEP plugins with multiple output fields are NOT guaranteed by the ENSEMBL VEP plugin type system to return stable field orderings across files.  For this reason, you must first ensure that any VCF files which are annotated separately (e.g. in a parallel VEP run on an HPC or other multicore compute system) have the same ordering of pipe-delimited INFO fields!

An example input line:

CSQ=A|downstream_gene_variant|MODIFIER|KLHL17|ENSG00000187961|Transcript|ENST00000463212|retained_intron|||||||||||4136|1|HGNC|24023|1|2|3|4

Multiple comma-separated annotations are all handled separately and a list structure is built.
