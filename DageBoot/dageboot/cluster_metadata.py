__author__ = 'dichenli'

cluster = {
    'region_name': 'us-east-1',
    'ami_ids': ['ami-68243102', 'ami-7721341d'],
    'user_name': 'ec2-user',
    'instance_type': 't2.micro',
    'volume_size': 9
}

# a template for proper security group for cassandra, need to fill in user id and 
security_group_template = {
    "Description": "DAGE Cassandra Security Group",
    "GroupName": "DAGECassandraSecurityGroup",
    "IpPermissions": [
        {
            "PrefixListIds": [],
            "FromPort": 50030,
            "IpRanges": [
                {
                    "CidrIp": "0.0.0.0/0"
                }
            ],
            "ToPort": 50030,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": []
        },
        {
            "PrefixListIds": [],
            "FromPort": 7199,
            "IpRanges": [],
            "ToPort": 7199,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": [
                {
                    "GroupId": ""
                }
            ]
        },
        {
            "PrefixListIds": [],
            "FromPort": 7001,
            "IpRanges": [],
            "ToPort": 7001,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": [
                {
                    "GroupId": ""
                }
            ]
        },
        {
            "PrefixListIds": [],
            "FromPort": 8012,
            "IpRanges": [
                {
                    "CidrIp": "0.0.0.0/0"
                }
            ],
            "ToPort": 8012,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": []
        },
        {
            "PrefixListIds": [],
            "FromPort": 61620,
            "IpRanges": [],
            "ToPort": 61620,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": [
                {
                    "GroupId": ""
                }
            ]
        },
        {
            "PrefixListIds": [],
            "FromPort": 7000,
            "IpRanges": [],
            "ToPort": 7000,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": [
                {
                    "GroupId": ""
                }
            ]
        },
        {
            "PrefixListIds": [],
            "FromPort": 8983,
            "IpRanges": [
                {
                    "CidrIp": "0.0.0.0/0"
                }
            ],
            "ToPort": 8983,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": []
        },
        {
            "PrefixListIds": [],
            "FromPort": 50031,
            "IpRanges": [],
            "ToPort": 50031,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": [
                {
                    "GroupId": ""
                }
            ]
        },
        {
            "PrefixListIds": [],
            "FromPort": 61621,
            "IpRanges": [],
            "ToPort": 61621,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": [
                {
                    "GroupId": ""
                }
            ]
        },
        {
            "PrefixListIds": [],
            "FromPort": 8888,
            "IpRanges": [
                {
                    "CidrIp": "0.0.0.0/0"
                }
            ],
            "ToPort": 8888,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": []
        },
        {
            "PrefixListIds": [],
            "FromPort": 22,
            "IpRanges": [
                {
                    "CidrIp": "0.0.0.0/0"
                }
            ],
            "ToPort": 22,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": []
        },
        {
            "PrefixListIds": [],
            "FromPort": 9290,
            "IpRanges": [],
            "ToPort": 9290,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": [
                {
                    "GroupId": ""
                }
            ]
        },
        {
            "PrefixListIds": [],
            "FromPort": 9160,
            "IpRanges": [],
            "ToPort": 9160,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": [
                {
                    "GroupId": ""
                }
            ]
        },
        {
            "PrefixListIds": [],
            "FromPort": 50060,
            "IpRanges": [
                {
                    "CidrIp": "0.0.0.0/0"
                }
            ],
            "ToPort": 50060,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": []
        },
        {
            "PrefixListIds": [],
            "FromPort": 9042,
            "IpRanges": [],
            "ToPort": 9042,
            "IpProtocol": "tcp",
            "UserIdGroupPairs": [
                {
                    "GroupId": ""
                }
            ]
        }
    ]
}


def replace_group_id(ip_permissions, group_id):
    for permission in ip_permissions:
        if len(permission['UserIdGroupPairs']) > 0:
            for pair in permission['UserIdGroupPairs']:
                pair['GroupId'] = group_id
    return ip_permissions