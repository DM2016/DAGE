__author__ = 'dichenli'
import re
from os import close

yaml = "/Users/dichenli/Documents/TPOT_project/DAGE/cassandraBoot/cassandra.yaml"
new_yaml = yaml + ".temp"
ip = "127.0.0.1"
seeds = "127.0.0.1"

listen_address_regex = re.compile(r"(^ *listen_address: *)(.*)($)")
rpc_address_regex = re.compile(r"(^ *rpc_address: *)(.*)($)")
seeds_regex = re.compile(r'(^.*- seeds: \")(.*)(\".*$)')
with open(yaml) as old_file:
    with open(new_yaml, 'w') as new_file:
        for line in old_file:
            line = listen_address_regex.sub(r'\g<1>%s\g<3>' % ip, line)
            line = rpc_address_regex.sub(r'\g<1>%s\g<3>' % ip, line)
            line = seeds_regex.sub(r'\g<1>%s\g<3>' % seeds, line)
            new_file.write(line)

