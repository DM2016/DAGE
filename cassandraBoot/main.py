import os

__author__ = 'dichenli'
'''Bootstrap cassandra from AMI, create a database that
contains all vep annotation data'''

import boto3
import datetime
from dateutil import tz
import time
import sys
import paramiko
from scp import SCPClient
from ec2_instance import *

session = boto3.Session(profile_name='aws150415', region_name='us-east-1')

# metadata of the cluster
ssh_key = SshKey(key_name='dage', file_path='/Users/dichenli/.ec2/dage.pem')
ami_ids = ['ami-68243102', 'ami-7721341d']
user_name = 'ec2-user'
security_group = 'tryDatastaxCassnadraNVirginia'
instance_type = 't2.micro'
volume_size = 9
cassandra_setup = '/Users/dichenli/Documents/TPOT_project/DAGE/cassandraBoot/cassandra_setup.py'
cassandra_boot = '/Users/dichenli/Documents/TPOT_project/DAGE/cassandraBoot/cassandra_boot.sh'


def launch_cluster():
    instances = map(
        lambda ami_id: Ec2Instance(
            boto_session=session, image_id=ami_id, user_name=user_name,
            ssh_key=ssh_key, security_group=security_group,
            instance_type=instance_type, volume_size=volume_size
        ), ami_ids
    )
    print "Launching instances"
    for index, instance in enumerate(instances):
        print "Launching instance " + str(index)
        instance.launch_instance()
    for index, instance in enumerate(instances):
        print "Waiting until instance " + str(index) + " is ready"
        instance.wait_until_instance_running()
        print "Instance ready, id: %s, private ip: %s, public ip: %s" % (
            instance.get_instance_id(),
            instance.get_private_ip(),
            instance.get_public_ip()
        )
        instance.tag_instance(key='Name', value='Cassandra_' + str(index))

    # instances = map(
    #     lambda id: Ec2Instance(
    #         boto_session=session, instance_id=id, user_name=user_name, ssh_key=ssh_key
    #     ), ['i-32b425af', 'i-34b425a9']
    # )

    print "All instances ready"
    seeds = '"' + ','.join(map(
        lambda inst: inst.get_private_ip(), instances
    )) + '"'
    print seeds
    for index, instance in enumerate(instances):
        instance.connect_ssh()
        instance.scp(files=cassandra_setup, remote_path='~/cassandra_setup.py')
        instance.scp(files=cassandra_boot, remote_path='~/cassandra_boot.sh')
        boot_cmd = '~/cassandra_boot.sh ' + instance.get_private_ip() + ' ' + seeds
        print "remote execute: " + boot_cmd
        print instance.ssh_command(boot_cmd)
        instance.close_ssh()


launch_cluster()

# TODO: 2. setup security group
# TODO: 3. launch spark with the information of the DB
# TODO: 4. In a cassandra cluster with opscenter, set up cluster info file so that opscenter works out of box
