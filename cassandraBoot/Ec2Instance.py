__author__ = 'dichenli'

import boto3
from aenum import Enum
import datetime
from dateutil import tz
import time
import sys


class Ec2State(Enum):
    pending = 1
    running = 2
    stopped = 3
    terminated = 4
    unavailable = 5


class Ec2FailureException(Exception):
    pass


class Ec2Instance:
    def launch_instance(self):
        if self.instance_id is not None:
            raise AttributeError('Cannot launch an instance when instance_id is already set')
        response = self.ec2_client.run_instances(
            DryRun=False, ImageId=self.image_id,
            MinCount=1, MaxCount=1,
            KeyName=self.key_name,
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
            print "Waiting until instance is running"
            self.wait_until_instance_running()
            self.update_profile()
        else:
            raise Ec2FailureException('Failed to launch the instance!')

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

    def __init__(self, boto_session=None, instance_id=None,
                 image_id=None,
                 key_name=None, security_group=None,
                 instance_type=None, volume_size=None):
        self.session = boto_session
        self.ec2_client = self.session.client('ec2')
        self.instance_id = instance_id
        self.instance_profile = None
        self.private_ip = None
        self.public_ip = None
        self.state = Ec2State.unavailable
        self.image_id = image_id
        self.key_name = key_name
        self.security_group = security_group
        self.instance_type = instance_type
        self.volume_size = volume_size
        if instance_id is not None:
            self.is_running() # update instance state
        if self.state is not Ec2State.unavailable:
            self.update_profile()
