## PySparkCassandra: a Cassandra populator for human genetic variant effect annotations.
####  Dichen Li and Brian S. Cole, PhD
##### Institute for Biomedical Informatics, University of Pennsylvania Perelman School of Medicine, Philadelphia PA

This directory contains Python source to populate a Cassandra database with genetic variant effect annotations.  The resulting database is then available for distributed access, e.g. by a Spark cluster such as DAGE.

populate_vep_cassandra.py: python script to populate cassandra database with sample data

NOTE: this populator currently only supports GZIP-compressed input data.  The format of the input data is 5-column digest extracted from VEP output VCF files: chrom, pos, ref, alt, and INFO.  The INFO field is parsed by functions within the Python source code.  Note that VEP plugins with multiple output fields are NOT guaranteed by the ENSEMBL VEP plugin type system to return stable field orderings across files.  For this reason, you must first ensure that any VCF files which are annotated separately (e.g. in a parallel VEP run on an HPC or other multicore compute system) have the same ordering of pipe-delimited INFO fields!

### An example input line:

#### CSQ=A|downstream_gene_variant|MODIFIER|KLHL17|ENSG00000187961|Transcript|ENST00000463212|retained_intron|||||||||||4136|1|HGNC|24023|1|2|3|4

Multiple comma-separated annotations are all handled separately and a collection of the annotations is built.  Here's an example of how that looks in Python:

### An example input line with multiple annotations:
#### 1	901994	G	A	CSQ=A|downstream_gene_variant|MODIFIER|KLHL17|ENSG00000187961|Transcript|ENST00000463212|retained_intron|||||||||||4136|1|HGNC|24023||||,A|upstream_gene_variant|MODIFIER|PLEKHN1|ENSG00000187583|Transcript|ENST00000480267|retained_intron|||||||||||4261|1|HGNC|25284||||

## Will be converted to (without line break or indent):
    (1, 901994, 'G', 'A',
        "[{
            vep: 'CSQ=A|downstream_gene_variant|MODIFIER|KLHL17|ENSG00000187961|Transcript|ENST00000463212|
            retained_intron|||||||||||4136|1|HGNC|24023|',
            lof: '', lof_filter: '', lof_flags: '', lof_info: '', others: ''
        }, {
            vep: 'A|upstream_gene_variant|MODIFIER|PLEKHN1|ENSG00000187583|Transcript|ENST00000480267|
            retained_intron|||||||||||4261|1|HGNC|25284|',
            lof: '', lof_filter: '', lof_flags: '', lof_info: '', others: ''
        }]"
    )
