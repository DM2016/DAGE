from botocore.exceptions import ClientError
import custom_exceptions
import cluster_metadata

__author__ = 'dichenli'


def get_default_vpc(ec2_client):
    response = ec2_client.describe_vpcs(Filters=[{
        'Name': 'is-default',
        'Values': ['true', ]
    }])
    vpcs = response[u'Vpcs']
    if len(vpcs) is not 1:
        raise custom_exceptions.VpcFailureException(
            'No default VPC exists in this account and region!')
    vpc_id = vpcs[0][u'VpcId']
    return Ec2Vpc(vpc_id)


class Ec2Vpc:
    def get_id(self):
        return self.vpc_id

    def __init__(self, vpc_id=None):
        self.vpc_id = vpc_id


def get_security_group_by_name(ec2_client=None, name=None):
    try:
        response = ec2_client.describe_security_groups(
            DryRun=False,
            GroupNames=[
                name,
            ]
        )
    except ClientError:
        return None
    groups = response[u'SecurityGroups']
    if len(groups) is not 1:
        return None
    group = groups[0]
    return SecurityGroup(
        ec2_client=ec2_client, group_id=group[u'GroupId'], name=name,
        description=group[u'Description'], vpc_id=group[u'VpcId']
    )


def delete_security_group(ec2_client=None, name=None):
    """Try to delete a security group, return boolean to indicate if successful"""
    try:
        ec2_client.delete_security_group(
            DryRun=False,
            GroupName=name
        )
        return True
    except Exception, e:
        # print e
        # TODO: find the exact exceptions to catch: http://goo.gl/xLG6DO
        return False


def create_security_group(
        ec2_client=None, name=None, description=None, vpc_id=None):
    """creates a new security group with the specified vpc name group name
        It may change the name by appending characters to avoid name conflict,
        or may delete an existing security group to avoid name conflict.
        This should be fine because our group is has its own specific name,
        unlikely to accidentally delete a user defined one
    """
    new_name = name
    count = 0
    # find a name that doesn't exist yet, or try to delete the existing one
    while True:
        group = get_security_group_by_name(ec2_client=ec2_client, name=new_name)
        if group is not None and \
                not delete_security_group(ec2_client=ec2_client, name=new_name):
            new_name = name + str(count)
            count += 1
        else:
            break

    return SecurityGroup(
        ec2_client=ec2_client, name=new_name,
        description=description, vpc_id=vpc_id
    ).create()


class SecurityGroup:
    def authorize_ingress_rules(self, ip_permissions):
        self.ec2_client.authorize_security_group_ingress(
            DryRun=False, GroupId=self.id, IpPermissions=ip_permissions)

    def get_id(self):
        return self.id

    def get_name(self):
        return self.name

    def create(self):
        response = self.ec2_client.create_security_group(
            DryRun=False,
            GroupName=self.name,
            Description=self.description,
            VpcId=self.vpc_id
        )
        self.id = response[u'GroupId']
        return self

    def __init__(self, ec2_client=None, group_id=None, name=None,
                 description=None, vpc_id=None):
        self.ec2_client = ec2_client
        self.id = group_id
        self.name = name
        self.description = description
        self.vpc_id = vpc_id


def generate_cassandra_security_group(ec2_client):
    print "Configuring security group"
    d_vpc = get_default_vpc(ec2_client)

    security_group = create_security_group(
        ec2_client=ec2_client, name=cluster_metadata
            .security_group_template['GroupName'],
        description=cluster_metadata.security_group_template['Description'],
        vpc_id=d_vpc.get_id()
    )

    ip_permissions = cluster_metadata.replace_group_id(
        ip_permissions=cluster_metadata.security_group_template['IpPermissions'],
        group_id=security_group.get_id()
    )
    security_group.authorize_ingress_rules(ip_permissions=ip_permissions)
    print "Created security group: " + security_group.get_id()
    return security_group
