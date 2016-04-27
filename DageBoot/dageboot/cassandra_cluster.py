__author__ = 'dichenli'

'''Bootstrap cassandra from AMI, create a database that
contains all vep annotation data'''

from ec2_instance import *
from cluster_metadata import *
import boto3
import pkg_resources, os


def get_resource(folder, file_name):
    return pkg_resources.resource_filename(__name__, os.path.join(folder, file_name))


def launch_cluster(
        ec2_key=None, key_file_path=None, aws_profile_name=None,
        aws_access_key_id=None, aws_secret_access_key=None):
    session = None
    if aws_access_key_id is not None and aws_secret_access_key is not None:
        session = boto3.Session(aws_access_key_id=aws_access_key_id,
                                aws_secret_access_key=aws_secret_access_key,
                                region_name=cluster['region_name'])
    else:
        session = boto3.Session(profile_name=aws_profile_name,
                                region_name=cluster['region_name'])

    ssh_key = SshKey(ec2_key=ec2_key, key_file_path=key_file_path)
    cassandra_setup = get_resource('resources', 'cassandra_setup.py')
    cassandra_boot = get_resource('resources', 'cassandra_boot.sh')
    security_group = 'tryDatastaxCassnadraNVirginia'

    instances = map(
        lambda ami_id: Ec2Instance(
            boto_session=session, image_id=ami_id, user_name=cluster['user_name'],
            ssh_key=ssh_key, security_group=security_group,
            instance_type=cluster['instance_type'], volume_size=cluster['volume_size']
        ), cluster['ami_ids']
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
    #         boto_session=session, instance_id=id, user_name=cluster['user_name'], ssh_key=ssh_key
    #     ), ['i-9fe06a18', 'i-2ae369ad']
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
