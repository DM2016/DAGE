## https://cassandra.apache.org/doc/cql3/CQL-3.0.html

from cassandra.cluster import Cluster
from datetime import datetime

KEYSPACE = "vep_1kgp"
TABLE = "vep_annotation"


cluster = Cluster(contact_points=["54.175.83.232"])
session = cluster.connect()
print "Connection established"
start_time = datetime.now()

# create KEYSPACE https://docs.datastax.com/en/cql/3.1/cql/cql_reference/create_keyspace_r.html
# SimpleStrategy https://docs.datastax.com/en/cassandra/1.2/cassandra/architecture/architectureDataDistributeReplication_c.html
session.execute(
    "CREATE KEYSPACE IF NOT EXISTS " + KEYSPACE +
    " WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1 }"
)
session.set_keyspace(KEYSPACE)

session.execute(
    "CREATE TABLE IF NOT EXISTS " + TABLE +
    "(key text PRIMARY KEY, value text)"
)


def insert(k, v):
    session.execute(
        "INSERT INTO " + TABLE + " (key, value) VALUES (%s, %s)",
        (k, v)
    )


dataDir = "/Users/dichenli/Documents/TPOT_project/VCF_VEP/"
f = open(dataDir + 'key_value_pairs', 'r')
count = 0
for line in f:
    list = line.split('\t')
    if len(list) != 5:
        print "Exception line: " + line
        continue
    key = "_".join(list[:4])
    value = list[4]
    insert(key, value)
    count = count + 1
    if count % 100 == 0:
        print count
f.close()
end_time = datetime.now()
print str(count) + " rows inserted, time used: " + str(end_time - start_time)


rows = session.execute("SELECT * FROM " + TABLE + " limit 5")

for row in rows:
    print row[0], row[1]
    