__author__ = 'dichenli'

from cassandra.cluster import Cluster

KEYSPACE = "vep_1kgp"
TABLE = "vep_annotation"


cluster = Cluster(contact_points=["54.175.83.232"])
session = cluster.connect()

session.execute("DESCRIBE keyspaces")
