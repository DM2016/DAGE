__author__ = 'dichenli'

import os
from aenum import Enum
import time
import sys
import paramiko
from scp import SCPClient
from exceptions import *

class SshKey:
    def __init__(self, ec2_key=None, key_file_path=None):
        self.key_name = ec2_key
        self.file_path = key_file_path

    def key(self):
        return self.key_name

    def path(self):
        return self.file_path


class Ec2State(Enum):
    pending = 1
    running = 2
    stopped = 3
    terminated = 4
    unavailable = 5



class Ec2Instance:
    def launch_instance(self):
        if self.instance_id is not None:
            raise AttributeError('Cannot launch an instance when instance_id is already set')
        response = self.ec2_client.run_instances(
            DryRun=False, ImageId=self.image_id,
            MinCount=1, MaxCount=1,
            KeyName=self.ssh_key.key(),
            SecurityGroups=[self.security_group],
            InstanceType=self.instance_type,
            BlockDeviceMappings=[{
                u'DeviceName': '/dev/sda1',
                u'Ebs': {
                    u'VolumeSize': self.volume_size,
                    u'DeleteOnTermination': True,
                    u'VolumeType': 'gp2'
                }
            }]
        )
        instances = response[u'Instances']
        if len(instances) > 0:
            self.instance_id = instances[0][u'InstanceId']
            self.state = Ec2State.pending
        else:
            raise Ec2FailureException('Failed to launch the instance!')
        return self

    def is_running(self):
        response = self.ec2_client.describe_instance_status(InstanceIds=[self.instance_id])
        if len(response[u'InstanceStatuses']) < 1:
            self.state = Ec2State.unavailable
        else:
            status = response[u'InstanceStatuses'][0]
            if status[u'InstanceStatus'][u'Status'] == 'ok' \
                    and status[u'SystemStatus'][u'Status'] == 'ok':
                self.state = Ec2State.running
        return self.state == Ec2State.running

    def update_profile(self):
        response = self.ec2_client.describe_instances(InstanceIds=[self.instance_id])
        if len(response[u'Reservations']) < 1 or \
                        len(response[u'Reservations'][0][u'Instances']) < 1:
            raise Ec2FailureException('Failed to get instance profile!')
        self.instance_profile = response[u'Reservations'][0][u'Instances'][0]
        self.private_ip = self.instance_profile[u'PrivateIpAddress']
        if u'PublicIpAddress' in self.instance_profile:
            self.public_ip = self.instance_profile[u'PublicIpAddress']
        return self

    def get_private_ip(self):
        if self.private_ip is None:
            self.update_profile()
        return self.private_ip

    def get_public_ip(self):
        if self.public_ip is None:
            self.update_profile()
        return self.public_ip

    def get_instance_id(self):
        return self.instance_id

    def wait_until_instance_running(self):
        while not self.is_running():
            sys.stdout.write('.')
            time.sleep(5)
        self.update_profile()
        sys.stdout.write('\n')
        return self

    def tag_instance(self, key, value):
        if self.state == Ec2State.unavailable:
            raise Ec2FailureException('Cannot tag a instance not launched yet')
        self.ec2_client.create_tags(
            Resources=[self.instance_id],
            Tags=[{
                'Key': key,
                'Value': value
            }]
        )
        return self

    def connect_ssh(self):
        if not self.is_running():
            raise Ec2FailureException('Cannot ssh to a instance not running yet')
        self.ssh_client = paramiko.SSHClient()
        self.ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.ssh_client.connect(self.get_public_ip(), username=self.user_name,
                         key_filename=os.path.expanduser(self.ssh_key.path()))
        self.scp_client = SCPClient(self.ssh_client.get_transport())
        return self

    def scp(self, files, remote_path):
        self.scp_client.put(files=files, remote_path=remote_path)
        return self

    def ssh_command(self, command):
        stdin, stdout, stderr = self.ssh_client.exec_command(command)
        return stdout.readlines(), stderr.readlines()

    def close_ssh(self):
        self.scp_client.close()
        self.ssh_client.close()

    def __init__(self, ec2_client=None, instance_id=None,
                 image_id=None, user_name=None,
                 ssh_key=None, security_group=None,
                 instance_type=None, volume_size=None):
        self.ec2_client = ec2_client
        self.instance_id = instance_id
        self.instance_profile = None
        self.private_ip = None
        self.public_ip = None
        self.state = Ec2State.unavailable
        self.image_id = image_id
        self.ssh_key = ssh_key
        self.security_group = security_group
        self.instance_type = instance_type
        self.volume_size = volume_size
        self.ssh_client = None
        self.scp_client = None
        self.user_name = user_name
        if instance_id is not None:
            self.is_running()  # update instance state
        if self.state is not Ec2State.unavailable:
            self.update_profile()
