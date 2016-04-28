from dageboot.ec2_network import generate_cassandra_security_group

__author__ = 'dichenli'

'''Bootstrap cassandra from AMI, create a database that
contains all vep annotation data'''

from ec2_instance import *
from cluster_metadata import *
import boto3
import pkg_resources, os


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
        raise AwsCredentialsException('aws-access-key-id and aws-secret-access-key '
                                      'must be provided simultaneously.')
    ec2_client = session.client('ec2')

    ssh_key = SshKey(ec2_key=ec2_key, key_file_path=key_file_path)
    cassandra_setup = get_resource('resources', 'cassandra_setup.py')
    cassandra_boot = get_resource('resources', 'cassandra_boot.sh')
    security_group = generate_cassandra_security_group(ec2_client)

    instances = map(
        lambda ami_id: Ec2Instance(
            ec2_client=ec2_client, image_id=ami_id, user_name=cluster['user_name'],
            ssh_key=ssh_key, security_group=security_group.get_name(),
            instance_type=cluster['instance_type'], volume_size=cluster['volume_size']
        ), cluster['ami_ids']
    )
    print "Launching instances"
    for index, instance in enumerate(instances):
        print "Launching instance " + str(index)
        instance.launch_instance()
    for index, instance in enumerate(instances):
        print "Waiting until instance " + str(index) + " is ready"
        print "Please check your AWS EC2 console, if the instance launching failed" \
              " (like status check failure), please terminate this process (ctrl+c)" \
              " and manually terminate all instances launched by it. "
        instance.wait_until_instance_running()
        print "Instance ready, id: %s, private ip: %s, public ip: %s" % (
            instance.get_instance_id(),
            instance.get_private_ip(),
            instance.get_public_ip()
        )
        instance.tag_instance(key='Name', value='Cassandra_' + str(index))

    # instances = map(
    #     lambda id: Ec2Instance(
    #         ec2_client=ec2_client, instance_id=id,
    #         user_name=cluster['user_name'], ssh_key=ssh_key
    #     ), ['i-8d73ec10', 'i-8e73ec13']
    # )

    print "All instances ready"
    seeds = '"' + ','.join(map(
        lambda inst: inst.get_private_ip(), instances
    )) + '"'
    print seeds
    for index, instance in enumerate(instances):
        instance.connect_ssh()
        print "Sending bootstrap scripts to remote host"
        instance.scp(files=cassandra_setup, remote_path='~/cassandra_setup.py')
        instance.scp(files=cassandra_boot, remote_path='~/cassandra_boot.sh')
        boot_cmd = '~/cassandra_boot.sh ' + instance.get_private_ip() + ' ' + seeds
        print "Bootstraping remote cassandra nodes with command: " + boot_cmd
        stdout_lines, stderr_lines = instance.ssh_command(boot_cmd)
        sys.stdout.write(''.join(stdout_lines))
        sys.stderr.write(''.join(stderr_lines))
        instance.close_ssh()
        print "Instance " + instance.get_instance_id() + "bootstrapping done"
    print "All done. You may access the cluster by the following endpoints: "
    print "\n".join(map(lambda inst: inst.get_public_ip(), instances))
