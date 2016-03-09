## https://cassandra.apache.org/doc/cql3/CQL-3.0.html

from cassandra.cluster import Cluster

cluster = Cluster()
session = cluster.connect('mykeyspace')
session.execute(
    """
    INSERT INTO event_attend (event_id, event_type, event_user_id)
    VALUES (%s, %s, %s)
    """,
    (2644, "haha", 1111)
)
rows = session.execute('SELECT event_id, event_type, event_user_id FROM event_attend')
for row in rows:
    print row.event_id, row.event_type, row[2]