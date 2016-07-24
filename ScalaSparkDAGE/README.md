## Distributed Annotation of Genetic Effects
### A reproducible, cloud-based annotator for the consequences (effects) of human genetic variation.

#### Dichen Li and Brian S. Cole, PhD
#### Institute for Biomedical Informatics, University of Pennsylvania Perelman School of Medicine, Philadelphia PA

DAGE is a repository of programs written in Scala, Python, and bash that provide distributed genetic variant effect annotation operations using Apache Spark and a cloud-hosted, user-instantiated or user-reinstanted (using AMI images for reproducibility) Cassandra cluster which hosts a database of variant effects (VEPDB - see PySparkCassandra for more information).

> IMPORTANT!
> DAGE is designed for AWS cloud services and requires the user to have to an AWS account.  All costs will be billed to the user, not to anybody else!
> Always keep your AWS account information private!

## Method:

DAGE reads data from S3 cloud storage in VCF format and builds a resilient distributed dataset (RDD), an abstraction provided by Apache Spark for distributed computation.  Methods for querying a Cassandra database containing variant effect annotations are provided by the spark-cassandra-connector, which exposes a Cassandra database to Spark as if it were an RDD.  These Spark-to-Cassandra queries utilize a 4-part compound key that uniquely identifies a genetic variant:

*chromosome    position    reference_allele    alternative_allele*

And the effects of the alternative allele for that genetic variant are returned and appended to the RDD that holds genetic variants. Output is then written in compressed VCF format.

## Build

1. Install sbt on your computer
   
    On Mac: http://www.scala-sbt.org/0.13/docs/Installing-sbt-on-Mac.html
   
    On Linux: http://www.scala-sbt.org/0.13/docs/Installing-sbt-on-Linux.html
   
    If you use homebrew, simply run:
    
    ```bash
    brew install sbt
    ```

2. Build and assemble the project

    In this directory where build.sbt file exists, run: 
    
    ```bash
    sbt assembly 
    ```
    
    A fat jar named **DAGE-assembly-x.x.x.jar** will be built under target/scala-2.10/ directory.


## Run on AWS EMR (Elastic MapReduce)

1. You need to have an AWS account (with necessary permissions), AWS access keys (access key ID and secret access key, see <http://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys>).
2. The instructions below are executed by AWS CLI (<https://aws.amazon.com/cli/>). You may choose to use AWS SDKs or website console as well. 
3. Launch a VEPDB cluster manually or use Dageboot (see <https://github.com/bryketos/DAGE/tree/master/DageBoot>), get the private IP address of any of the VEPDB EC2 instances.
4. Upload the DAGE jar built above to an S3 bucket. 
5. Create an EC2 ssh key pair on AWS. Please see the instructions on <http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html>
6. Create an EMR cluster with the following AWS CLI command template. The cluster must be created under the same AWS region and VPC as the VEPDB.
    
    ```bash
    aws emr create-cluster --applications Name=Ganglia Name=Spark \
    --ec2-attributes '{"KeyName":"<ec2_ssh_key_pair_name>","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"<subnet_id>"}' \
    --service-role EMR_DefaultRole --enable-debugging \
    --release-label <emr-4.6.0, or newer> \
    --log-uri '<s3://path/to/log/directory>' \
    --name '<custom_job_name>' \
    --instance-groups \
    '[{"InstanceCount":<number>,"InstanceGroupType":"CORE","InstanceType":"<instance_type>","Name":"Core Instance Group"},'\
    '{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"<instance_type>","Name":"Master Instance Group"}]' \
    --configurations '[{"Classification":"capacity-scheduler",'\
    '"Properties":{"yarn.scheduler.capacity.resource-calculator":'\
    '"org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"}},'\
    '{"Classification":"spark","Properties":{'\
    '"maximizeResourceAllocation":"true",'\
    '"spark.dynamicAllocation.enabled":"false",'\
    '"spark.executor.instances":"<number>"}}]' \
    --profile <aws profile> --region us-east-1
    ```
    
    Explanations: 
        
        subnet_id: There should be default VPC and subnet associated with your account. See <http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/default-vpc.html>. It is highly recommended to use the same subnet as the VEPDB.
        
        log-uri: an S3 directory to store EMR job logs. It contains the logs from EMR, Yarn, Spark, and standard output.
        
        InstanceCount: the number of EC2 instances in CORE instance group. 
        
        InstanceType: Please see <https://aws.amazon.com/ec2/instance-types/> for instance types. For example, m3.xlarge should be good to start with.
        
        configurations: Hadoop, Yarn and Spark are highly tunable. EMR facilitates you to pass in configurations at launch. The configurations here are just examples.
        
        spark.executor.instances: Default number of instances to work on each Spark job. You may set it to be the same as core instance count to maximize execution capacity.
        
        profile: AWS profile, see <http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration>

7. Launch DAGE Spark job on the cluster created above. Below is an example of useful options. More options can be viewed by passing in '--help' parameter. The help information output is available in S3 log directory.
    
    ```bash
    aws emr add-steps --cluster-id '<ID of cluster created above>' \
    --steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
    '"--num-executors","<optional number of executors specific to this job>",'\
    '"s3://<path/to/DAGE-assembly-x.x.x.jar>",'\
    '"-i","s3://<path/to/input/VCF/files>",'\
    '"-o","s3://<path/to/output/directory>",'\
    '"--export-missing-keys","s3://<path/to/missing/keys/output for keys in VCF files not found in VEPDB>/",'\
    '"--flip-allele",'\
    '"--flip-strand",'\
    '"-h","<VEPDB private IP address, use public if VEPDB is in a different VPC or region>",'\
    '"--name","<job name, a subdirectory of this name will be created under the output directory>",'\
    '"--parallelism","<spark.default.parallelism value>",'\
    '"--aws-access-key-id","<AWS key ID, necessary for Spark to download file from S3>",'\
    '"--aws-secret-access-key","<AWS secret access key>"],'\
    '"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
    '"Properties":"","Name":"<spark job name>"}]' \
    --profile brian --region us-east-1
    ```

8. Once the job is done, the VEP annotated VCF files should be available in the output S3 directory you specified. 
9. Remember to terminate the EMR cluster and VEPDB cluster if you don't need them any more.

## Run on your own infrastructure

The jar created in the step above can be submitted to any Spark cluster to run. You may need to manually copy the DAGE jar to the file system available to Spark. Please refer to <http://spark.apache.org/docs/latest/submitting-applications.html> for general spark-submit instructions.

The job launch script template is below:

```bash
<path/to/spark/home>/bin/spark-submit --class Main <path/to/DAGE-assembly-x.x.x.jar> -i <FileSystemProtocol://><path/to/input/VCF/files> -o <fs-protocol://><path/to/output/directory> -h <VEPDB ip> <other options>
<path/to/spark/home>/bin/spark-submit --class Main <path/to/DAGE-assembly-x.x.x.jar> --help  # to print out help information and show all available options. It is printed out to STDOUT
```

You may choose to connect DAGE to the VEPDB on AWS. Just pass the public IP addresses of the VEPDB to DAGE as an argument as always. If you want to build a private VEPDB, you may instantiate a Cassandra cluster, and use the populate_cassandra_gzip.py script to populate the DB with VEP annotation data.
