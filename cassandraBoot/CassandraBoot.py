__author__ = 'dichenli'
'''Bootstrap cassandra from AMI, create a database that
contains all vep annotation data'''

import boto3
import datetime
from dateutil import tz
import time
import sys
from Ec2Instance import *

session = boto3.Session(profile_name='aws150415', region_name='us-east-1')

# instance = Ec2Instance(boto_session=session, image_id='ami-68243102',
#                        key_name='trycassandra', security_group='tryDatastaxCassnadraNVirginia',
#                        instance_type='t2.micro', volume_size=8)
#
# print "Launch instance %s" % 'ami-68243102'
# instance.launch_instance()
# instance.tag_instance(key='Name', value='haha3')

instance = Ec2Instance(boto_session=session, instance_id='i-257ff4b8')

print "Instance running, id: %s, private ip: %s, public ip: %s" % (
    instance.get_instance_id(),
    instance.get_private_ip(),
    instance.get_public_ip()
)
