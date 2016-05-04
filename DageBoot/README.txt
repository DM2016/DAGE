dageboot: Distributed Annotation of Genetic Effects Bootstrap

It is a tool to automate the launching of DAGE Cassandra database cluster.
The database is under development, and is not yet available to the public.

Requirements:
    1. Linux or Mac OS
    2. python 2.7 (other versions may work but not tested yet)
    3. pip installed, see https://pip.pypa.io/en/stable/installing/
    4. An AWS account accessible to us-east-1 (North Virginia) region
    5. AWS root user or IAM user with AmazonEC2FullAccess policy attached
    6. AWS access key or AWS credentials profile
    7. Funding for launching and hosting the cluster

Installation:
    On command line, run:
        pip install dageboot

Running:
    On command line, run:
        dageboot --key-pair <EC2 key pair name> \
        --key-file <path to EC2 key pair file> \
        --aws-profile-name <AWS credentials profile>
    To see more options for running, run:
        dageboot --help

