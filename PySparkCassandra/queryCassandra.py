__author__ = 'dichenli'

from cassandra.cluster import Cluster

KEYSPACE = "vep_1kgp_2"
TABLE = "vep_annotation"


cluster = Cluster(contact_points=["54.164.197.70"])
session = cluster.connect()

session.execute("DESCRIBE keyspaces")
