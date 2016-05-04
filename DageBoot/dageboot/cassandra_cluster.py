import boto3
import pkg_resources
import cluster_metadata
from cluster_metadata import cluster
import custom_exceptions
from dageboot.ec2_network import generate_cassandra_security_group
import ec2_instance
import sys
import os

__author__ = 'dichenli'


def get_resource(folder, file_name):
    """Use this method to get the absolute path of the static files
    packed inside the package"""
    return pkg_resources.resource_filename(__name__, os.path.join(folder, file_name))


def launch_cluster(
        ec2_key=None, key_file_path=None, aws_profile_name=None,
        aws_access_key_id=None, aws_secret_access_key=None):
    """Launch a cassandra cluster with meta info available in cluster_metadata"""
    if aws_access_key_id is not None and aws_secret_access_key is not None:
        session = boto3.Session(aws_access_key_id=aws_access_key_id,
                                aws_secret_access_key=aws_secret_access_key,
                                region_name=cluster['region_name'])
    elif aws_access_key_id is None and aws_secret_access_key is None:
        session = boto3.Session(profile_name=aws_profile_name,
                                region_name=cluster['region_name'])
    else:
        raise custom_exceptions.AwsCredentialsException(
            'aws-access-key-id and aws-secret-access-key must be provided simultaneously.')
    ec2_client = session.client('ec2')

    print "Bootstrapping DAGE cassandra cluster"
    ssh_key = ec2_instance.SshKey(ec2_key=ec2_key, key_file_path=key_file_path)
    cassandra_setup = get_resource('resources', 'cassandra_setup.py')
    cassandra_boot = get_resource('resources', 'cassandra_boot.sh')
    security_group = generate_cassandra_security_group(ec2_client)

    print "Launching EC2 instances in region " + cluster_metadata.cluster['region_name']
    print "If it takes too long, please check your AWS EC2 console. " \
          "If some of the instances failed (like status check failure), " \
          "please terminate this process (ctrl+c) " \
          "and manually terminate all instances launched by it. "
    instances = map(
        lambda ami_id: ec2_instance.Ec2Instance(
            ec2_client=ec2_client, image_id=ami_id,
            user_name=cluster['user_name'],
            ssh_key=ssh_key, security_group=security_group.get_name(),
            instance_type=cluster['instance_type'],
            volume_size=cluster['volume_size']
        ), cluster['ami_ids']
    )
    for index, instance in enumerate(instances):
        print "Launching instance " + str(index)
        instance.launch_instance()
        instance.tag_instance(key='Name', value='Cassandra_' + str(index))
    for index, instance in enumerate(instances):
        print "Waiting until instance " + str(index) + " is ready"
        instance.wait_until_instance_running()
        print "Instance ready, id: %s, private ip: %s, public ip: %s" % (
            instance.get_instance_id(),
            instance.get_private_ip(),
            instance.get_public_ip()
        )
    print "All instances ready"

    # instances = map(
    #     lambda id: Ec2Instance(
    #         ec2_client=ec2_client, instance_id=id,
    #         user_name=cluster['user_name'], ssh_key=ssh_key
    #     ), ['i-8d73ec10', 'i-8e73ec13']
    # )

    print "Sending scripts to remote nodes"
    seeds = '"' + ','.join(map(
        lambda inst: inst.get_private_ip(), instances
    )) + '"'
    for index, instance in enumerate(instances):
        instance.connect_ssh()
        instance.scp(files=cassandra_setup, remote_path='~/cassandra_setup.py')
        instance.scp(files=cassandra_boot, remote_path='~/cassandra_boot.sh')
        boot_cmd = '~/cassandra_boot.sh ' + instance.get_private_ip() + ' ' + seeds
        print "Bootstrapping cassandra server on " + instance.get_instance_id() + \
              " with command: " + boot_cmd
        stdout_lines, stderr_lines = instance.ssh_command(boot_cmd)
        sys.stdout.write(''.join(stdout_lines))
        sys.stderr.write(''.join(stderr_lines))
        instance.close_ssh()
        print "Bootstrapping " + instance.get_instance_id() + " done"
    print "All done. You may access the cluster by the following endpoints: "
    print "\n".join(map(lambda inst: inst.get_public_ip(), instances))
