dataDir = "/Users/dichenli/Documents/TPOT_project/tryPySpark/Ceph/foo/"
f = open(dataDir + 'Ceph_samples', 'r')
header1 = f.readline()
header2 = f.readline()
count = 0
for line in f:
    print line
    count = count + 1
print count