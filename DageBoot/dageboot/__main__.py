__author__ = 'dichenli'

from dageboot import *
import argparse


def main():
    parser = argparse.ArgumentParser(
        prog='dageboot', description='DAGE Cassandra Cluster Launcher')
    parser.add_argument('--key-pair', type=str, required=True,
                        help='The name of key pair to ssh to EC2')
    parser.add_argument('--key-file', type=str, required=True,
                        help='The file path to the ec2 key pair (usually a .pem file)')
    parser.add_argument('--aws-profile-name', type=str, default='default',
                        help='The AWS credentials profile name')
    parser.add_argument('--aws-access-key-id', type=str, default=None,
                        help='The AWS access key id')
    parser.add_argument('--aws-secret-access-key', type=str, default=None,
                        help='The AWS secret access key')
    
    args = parser.parse_args()
    launch_cluster(aws_access_key_id=args.aws_access_key_id,
                   aws_secret_access_key=args.aws_secret_access_key,
                   aws_profile_name=args.aws_profile_name,
                   ec2_key=args.key_pair,
                   key_file_path=args.key_file)


if __name__ == "__main__":
    main()



# must done:
# TODO: setup security group

# very important to have
# TODO: implement function to restart existing cluster (user need to provide instance ids)
# TODO: launch spark with the information of the DB
# TODO: use command line to offer parameters: instance type, volume size
# TODO: In a cassandra cluster with opscenter, set up cluster info file so that opscenter works out of box

# maybe in the long term
# TODO: support mutliple regions
