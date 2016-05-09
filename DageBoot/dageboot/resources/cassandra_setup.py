import os

__author__ = 'dichenli'
import re
import sys
from time import gmtime, strftime

yaml = sys.argv[1]
new_yaml = yaml + ".temp"
ip = sys.argv[2]
seeds = sys.argv[3]

listen_address_regex = re.compile(r"(^ *listen_address: *)(.*)($)")
rpc_address_regex = re.compile(r"(^ *rpc_address: *)(.*)($)")
seeds_regex = re.compile(r'(^.*- seeds: \")(.*)(\".*$)')
endpoint_snitch_regex = re.compile(r'(^ *endpoint_snitch: *)(.*)($)')
with open(yaml) as old_file:
    with open(new_yaml, 'w') as new_file:
        for line in old_file:
            line = listen_address_regex.sub(r'\g<1>%s\g<3>' % ip, line)
            line = rpc_address_regex.sub(r'\g<1>%s\g<3>' % ip, line)
            line = seeds_regex.sub(r'\g<1>%s\g<3>' % seeds, line)
            line = endpoint_snitch_regex.sub(r'\g<1>GossipingPropertyFileSnitch\g<3>', line)
            new_file.write(line)
        new_file.close()
        old_file.close()

os.rename(yaml, yaml + strftime("%Y-%m-%d %H-%M-%S", gmtime()) + '.bak')
os.rename(new_yaml, yaml)
