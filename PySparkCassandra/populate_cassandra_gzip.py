__author__ = 'dichenli'

## https://cassandra.apache.org/doc/cql3/CQL-3.0.html

from cassandra.cluster import Cluster
from cassandra import ConsistencyLevel
from datetime import datetime
import gzip

KEYSPACE = "vep_1kgp"
TABLE = "vep_annotation"

cluster = Cluster(contact_points=["127.0.0.1"])
session = cluster.connect()
print "Connection established"

# TODO change class and rep-factor before real population job
# create KEYSPACE https://docs.datastax.com/en/cql/3.1/cql/cql_reference/create_keyspace_r.html
# SimpleStrategy https://docs.datastax.com/en/cassandra/1.2/cassandra/architecture/architectureDataDistributeReplication_c.html
session.execute(
    "CREATE KEYSPACE IF NOT EXISTS " + KEYSPACE +
    " WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 3 }"
)
session.set_keyspace(KEYSPACE)
session.default_consistency_level = ConsistencyLevel.ALL

session.execute(
    "CREATE TABLE IF NOT EXISTS " + TABLE +
    "(key text PRIMARY KEY, value text)"# +
    # " WITH compression = { 'sstable_compression' : '' }"
)


def insert(k, v):
    session.execute(
        "INSERT INTO " + TABLE + " (key, value) VALUES (%s, %s)",
        (k, v)
    )

#TODO support multiple files
dataDir = "/Users/dichenli/Downloads/"
f = gzip.open(dataDir + '1kGP_variants_VEP_LOFTEE_key_value_pairs.tsv.gz', 'rb')
count = 0
lines = 84801901 # lines of the file
start_time = datetime.now()
for line in f:
    list = line.split('\t')
    # print line
    if len(list) != 5:
        print "Exception line: " + line
        continue
    key = "_".join(list[:4])
    value = list[4]
    insert(key, value)
    count = count + 1
    if count % 1000 == 0:
        percent = float(count) * 100 / lines
        time_left = (datetime.now() - start_time) * (lines - count) / count
        print str(percent) + "% done, est. time spent: " + str(time_left)
f.close()
print str(count) + " rows inserted"

#read 5 lines, just to assure writing is successful
rows = session.execute("SELECT * FROM " + TABLE + " limit 5")

for row in rows:
    print row[0], row[1]
