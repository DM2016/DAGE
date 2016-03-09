# This file converts GEN file format to VCF file using python-spark. It's only half done.

from pyspark import SparkContext, SparkConf
import re

appName = "demo1"
master = "local"
conf = SparkConf().setAppName(appName).setMaster(master)
sc = SparkContext(conf=conf)

protocol = "file://"
dataDir = "/Users/dichenli/Documents/TPOT_project/tryPySpark/Ceph/foo/"
# wholeTextFiles: the whole file becomes a giant string. The method emits (fileName, fileContent) pair
# Therefore, we should avoid very large files
# False: do not use Unicode. This will save space since we only have ASCII in files
infoWholeFiles = sc.wholeTextFiles(protocol + dataDir + "Ceph_GoNL_1KG_haps_chr*-95-100Mb_info.gz", None, False)
hapsWholeFiles = sc.wholeTextFiles(protocol + dataDir + "Ceph_GoNL_1KG_haps_chr*-95-100Mb_haps.gz", None, False)

def get_chr_num_from_filename(filename):
    """parse file name and extract the chromosome number"""
    matched = re.match(r'^.*Ceph_.*chr(\d{1,2}).*.gz$', filename)
    return matched.group(1)  # it should always match, or there is bug or we need different regex


def add_chr_num_column(pair, remove_head):
    """remove_head: boolean, if we need to remove the first line from file content"""
    filename = pair[0]
    file_content = pair[1]
    chr_num = get_chr_num_from_filename(filename)
    lines = file_content.split('\n')
    if (remove_head):
        lines = lines[1:]
    return [(lambda line: chr_num + ' ' + line)(line) for line in lines]


info = infoWholeFiles.flatMap(lambda pair: add_chr_num_column(pair, True))
haps = hapsWholeFiles.flatMap(lambda pair: add_chr_num_column(pair, False))


def zipped_to_list(pair):
    l1 = pair[0].split(' ')
    l2 = pair[1].split(' ')
    return l1 + l2[4:]


# zipped is a line-by-line concatenation of haps and info files
zipped = info.zip(haps).map(lambda pair: zipped_to_list(pair))



for k in zipped.sample(False, 0.0001, 81).collect():
    print len(k)

sc.stop()

"""


Problems:
1. rename: The file names contain '/', which cause spark to crash.
But we cannot rename file in S3. The only way to do it is copy file to new location, then delete the old one.
See http://stackoverflow.com/questions/21184720/how-to-rename-files-and-folder-in-amazon-s3
This could be painfully slow: https://github.com/boto/boto/issues/793
So maybe we need to rename the files in local disk, then upload them to S3 (which could also be very slow)
Any other ways to do them?

2. S3 naming: It could be very slow if all file names have the same prefix.
The solution is a random or frequently changing prefix.
http://docs.aws.amazon.com/AmazonS3/latest/dev/request-rate-perf-considerations.html
S3 name is at most 1024 bytes http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingMetadata.html#object-keys

3. Performance: I guess the biggest performance bottleneck is IO, especially with S3
A post about optimization over S3 when we have a large number of small files:
https://forums.databricks.com/questions/480/how-do-i-ingest-a-large-number-of-files-from-s3-my.html

4. Choose EMR instance: by the pricing information, if we choose the same instance type, it's always
better to use larger instance over smaller one, unless our job is small.
https://aws.amazon.com/ec2/instance-types/#memory-optimized
https://aws.amazon.com/elasticmapreduce/pricing/
However, we need to choose the best instance type. We probably want memory optimized

5. add header to VCF: http://stackoverflow.com/questions/26157456/add-a-header-before-text-file-on-save-in-spark
Here only one header is added to the first partition of the output file.
To add header to each partition, we may try .glom() method of RDD

Details:
1. use of RDD.cache()? When and how is it useful?
2. use dataframe? Is it necessary? It seems we don't need it because we only need inline operations
    http://spark.apache.org/docs/latest/sql-programming-guide.html#interoperating-with-rdds
    http://stackoverflow.com/questions/31508083/difference-between-dataframe-and-rdd-in-spark
# from pyspark.sql import SQLContext, Row
# sqlContext = SQLContext(sc)
# rows = zipped.map(lambda list: Row(rs_id=list[1], ...))
"""