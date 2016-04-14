__author__ = 'dichenli'

## https://cassandra.apache.org/doc/cql3/CQL-3.0.html

from cassandra.cluster import Cluster
from cassandra import ConsistencyLevel
from cassandra.query import SimpleStatement
from datetime import datetime
import gzip
import sys

KEYSPACE = "vep_1kgp"
TABLE = "vep_annotation"

cluster = Cluster(contact_points=sys.argv[2:])
session = cluster.connect()
print "Connection established"

# create KEYSPACE https://docs.datastax.com/en/cql/3.1/cql/cql_reference/create_keyspace_r.html
# SimpleStrategy https://docs.datastax.com/en/cassandra/1.2/cassandra/architecture/architectureDataDistributeReplication_c.html
session.execute(
    "CREATE KEYSPACE IF NOT EXISTS " + KEYSPACE +
    " WITH replication = {'class': 'NetworkTopologyStrategy', 'us-east': 3 }"
)
session.set_keyspace(KEYSPACE)

session.execute(
    "CREATE TABLE IF NOT EXISTS " + TABLE +
    "(key text PRIMARY KEY, value text)"# + " WITH compression = { 'sstable_compression' : '' }"
)


def insert(k, v):
    query = SimpleStatement("INSERT INTO " + TABLE + " (key, value) VALUES (%s, %s)",
        consistency_level=ConsistencyLevel.ALL)
    session.execute(query, (k, v))

f = gzip.open(sys.argv[1], 'rb')
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
        print str(percent) + "% done, est. time left: " + str(time_left)
f.close()
print str(count) + " rows inserted, time spent: " + str(datetime.now() - start_time)

# 84801901 rows inserted, time spent: 1 day, 23:41:03.094630