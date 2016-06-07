#!/usr/bin/env bash
aws emr create-cluster --applications Name=Hadoop Name=Hive Name=Pig Name=Hue Name=Spark \
--ec2-attributes '{"KeyName":"dage","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-884232ff","EmrManagedSlaveSecurityGroup":"sg-3c662558","EmrManagedMasterSecurityGroup":"sg-33662557"}' \
--service-role EMR_DefaultRole --enable-debugging --release-label emr-4.5.0 \
--log-uri 's3n://dage-spark-data/logs/' --name 'My cluster' \
--instance-type m4.xlarge --instance-count 4 --region us-east-1 \
--configurations https://s3.amazonaws.com/dage-spark-data/jars/emrMaximizeResourceAllocation.json \
--profile aws150415 --region us-east-1

#10K lines
#aws emr add-steps --cluster-id 'j-38GLUO3PMCRM1' --steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main","s3://dage-spark-data/jars/Simple_Project-assembly-0.0.1.jar","-i","s3://dage-spark-data/input/first_ten_thousand_lines_of_1kGP_chr1.vcf","-o","s3://dage-spark-data/output/10000lines/","-h","54.197.194.162","--export-missing-keys","s3://dage-spark-data/miss/10000lines/","--aws-access-key-id","AKIAJAV75BJ5HBA4MLUA","--aws-secret-access-key","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"],"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar","Properties":"","Name":"Lines10000"}]' --profile aws150415 --region us-east-1

#
aws emr add-steps --cluster-id 'j-38GLUO3PMCRM1' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage-spark-data/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://dage-spark-data/input/clean-merged-neighbor.vcf",'\
'"-o","s3://dage-spark-data/output/neighbor_1/",'\
'"-h","54.197.194.162",'\
'"--export-missing-keys","s3://dage-spark-data/miss/neighbor_1/",'\
'"--aws-access-key-id","AKIAJAV75BJ5HBA4MLUA",'\
'"--aws-secret-access-key","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"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"Basic"}]' \
--profile aws150415 --region us-east-1

aws emr add-steps --cluster-id 'j-38GLUO3PMCRM1' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage-spark-data/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://dage-spark-data/input/clean-merged-neighbor.vcf",'\
'"-o","s3://dage-spark-data/output/neighbor_1/",'\
'"-h","54.197.194.162",'\
'"-s",'\
'"--name","SortResult",'\
'"--export-missing-keys","s3://dage-spark-data/miss/neighbor_1/",'\
'"--aws-access-key-id","AKIAJAV75BJ5HBA4MLUA",'\
'"--aws-secret-access-key","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"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"SortResult"}]' \
--profile aws150415 --region us-east-1

aws emr add-steps --cluster-id 'j-38GLUO3PMCRM1' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage-spark-data/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://dage-spark-data/input/clean-merged-neighbor.vcf",'\
'"-o","s3://dage-spark-data/output/neighbor_1/",'\
'"-h","54.165.231.90",'\
'"--name","r3.2xlarge2",'\
'"--export-missing-keys","s3://dage-spark-data/miss/neighbor_1/",'\
'"--aws-access-key-id","AKIAJAV75BJ5HBA4MLUA",'\
'"--aws-secret-access-key","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"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"BasicWith r3.2xlarge2"}]' \
--profile aws150415 --region us-east-1

aws emr add-steps --cluster-id 'j-38GLUO3PMCRM1' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage-spark-data/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://dage-spark-data/input/clean-merged-neighbor.vcf",'\
'"-o","s3://dage-spark-data/output/neighbor_1/",'\
'"-h","54.197.194.162",'\
'"--partitions","1",'\
'"--export-missing-keys","s3://dage-spark-data/miss/neighbor_1/",'\
'"--aws-access-key-id","AKIAJAV75BJ5HBA4MLUA",'\
'"--aws-secret-access-key","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"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"Partition1"}]' \
--profile aws150415 --region us-east-1

aws emr add-steps --cluster-id 'j-38GLUO3PMCRM1' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage-spark-data/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://dage-spark-data/input/clean-merged-neighbor.vcf",'\
'"-o","s3://dage-spark-data/output/neighbor_1/",'\
'"-h","54.152.83.70",'\
'"--name","r3large",'\
'"--export-missing-keys","s3://dage-spark-data/miss/neighbor_1/",'\
'"--aws-access-key-id","AKIAJAV75BJ5HBA4MLUA",'\
'"--aws-secret-access-key","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"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"BasicWith r3.large"}]' \
--profile aws150415 --region us-east-1

aws emr add-steps --cluster-id 'j-38GLUO3PMCRM1' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage-spark-data/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://dage-spark-data/input/clean-merged-neighbor.vcf",'\
'"-o","s3://dage-spark-data/output/neighbor_1/",'\
'"-h","54.152.83.70",'\
'"--name","r3large2",'\
'"--export-missing-keys","s3://dage-spark-data/miss/neighbor_1/",'\
'"--aws-access-key-id","AKIAJAV75BJ5HBA4MLUA",'\
'"--aws-secret-access-key","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"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"BasicWith r3.large2"}]' \
--profile aws150415 --region us-east-1

aws emr add-steps --cluster-id 'j-38GLUO3PMCRM1' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage-spark-data/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://dage-spark-data/input/clean-merged-neighbor.vcf",'\
'"-o","s3://dage-spark-data/output/neighbor_1/",'\
'"-h","54.152.83.70",'\
'"--name","r3large3",'\
'"--export-missing-keys","s3://dage-spark-data/miss/neighbor_1/",'\
'"--aws-access-key-id","AKIAJAV75BJ5HBA4MLUA",'\
'"--aws-secret-access-key","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"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"BasicWith r3.large3"}]' \
--profile aws150415 --region us-east-1

aws emr add-steps --cluster-id 'j-1GJP3MUQQ5NLY' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage-spark-data/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://dage-spark-data/input/clean-merged-neighbor.vcf",'\
'"-o","s3://dage-spark-data/output/neighbor_1/",'\
'"-h","54.175.249.244",'\
'"--name","r3xlarge",'\
'"--export-missing-keys","s3://dage-spark-data/miss/neighbor_1/",'\
'"--aws-access-key-id","AKIAJAV75BJ5HBA4MLUA",'\
'"--aws-secret-access-key","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"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"BasicWith r3.xlarge"}]' \
--profile aws150415 --region us-east-1

aws emr add-steps --cluster-id 'j-1GJP3MUQQ5NLY' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage-spark-data/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://dage-spark-data/input/clean-merged-neighbor.vcf",'\
'"-o","s3://dage-spark-data/output/neighbor_1/",'\
'"-h","54.175.249.244",'\
'"--name","r3xlarge",'\
'"--export-missing-keys","s3://dage-spark-data/miss/neighbor_1/",'\
'"--aws-access-key-id","AKIAJAV75BJ5HBA4MLUA",'\
'"--aws-secret-access-key","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"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"BasicWith r3.xlarge"}]' \
--profile aws150415 --region us-east-1

aws emr add-steps --cluster-id 'j-1GJP3MUQQ5NLY' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage-spark-data/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://dage-spark-data/input/clean-merged-neighbor.vcf",'\
'"-o","s3://dage-spark-data/output/neighbor_1/",'\
'"-h","54.85.210.74",'\
'"--name","r3xlarge_reboot",'\
'"--export-missing-keys","s3://dage-spark-data/miss/neighbor_1/",'\
'"--aws-access-key-id","AKIAJAV75BJ5HBA4MLUA",'\
'"--aws-secret-access-key","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"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"BasicWith r3.xlarge_reboot"}]' \
--profile aws150415 --region us-east-1

aws emr add-steps --cluster-id 'j-60S5A53LGNCZ' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage-spark-data/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://dage-spark-data/input/clean-merged-neighbor.vcf",'\
'"-o","s3://dage-spark-data/output/neighbor_1/",'\
'"-h","54.85.210.74",'\
'"--name","oldDB_newEMR",'\
'"--export-missing-keys","s3://dage-spark-data/miss/neighbor_1/",'\
'"--aws-access-key-id","AKIAJAV75BJ5HBA4MLUA",'\
'"--aws-secret-access-key","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"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"oldDB_newEMR"}]' \
--profile aws150415 --region us-east-1

aws emr add-steps --cluster-id 'j-60S5A53LGNCZ' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage-spark-data/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://dage-spark-data/input/clean-merged-neighbor.vcf",'\
'"-o","s3://dage-spark-data/output/neighbor_1/",'\
'"-h","54.173.2.84",'\
'"--name","newDB_oldEMR",'\
'"--export-missing-keys","s3://dage-spark-data/miss/neighbor_1/",'\
'"--aws-access-key-id","AKIAJAV75BJ5HBA4MLUA",'\
'"--aws-secret-access-key","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"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"newDB_oldEMR"}]' \
--profile aws150415 --region us-east-1

#########Using Brian's account
aws emr create-cluster --applications Name=Ganglia Name=Spark \
--ec2-attributes '{"KeyName":"dage_brian","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-3402686c"}' \
--service-role EMR_DefaultRole --enable-debugging --release-label emr-4.6.0 \
--log-uri 's3n://aws-logs-255141198570-us-east-1/elasticmapreduce/' --name 'cluster1' \
--instance-groups \
'[{"InstanceCount":3,"InstanceGroupType":"CORE","InstanceType":"m3.xlarge","Name":"Core Instance Group"},'\
'{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"m3.xlarge","Name":"Master Instance Group"}]' \
--configurations '[{"Classification":"capacity-scheduler",'\
'"Properties":{"yarn.scheduler.capacity.resource-calculator":'\
'"org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"}},'\
'{"Classification":"spark","Properties":{"maximizeResourceAllocation":"true"}},'\
'{"Classification":"spark-defaults","Properties":{'\
'"spark.dynamicAllocation.enabled":"true","spark.executor.instances":"0"}}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-NZGBT1PWKG54' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.164.123",'\
'"--name","4Xm4.xlarge",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4Xm4.xlarge"}]' \
--profile brian --region us-east-1


aws emr create-cluster --applications Name=Ganglia Name=Spark \
--ec2-attributes '{"KeyName":"dage_brian","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-3402686c"}' \
--service-role EMR_DefaultRole --enable-debugging --release-label emr-4.6.0 \
--log-uri 's3n://aws-logs-255141198570-us-east-1/elasticmapreduce/' --name 'cluster1' \
--instance-groups \
'[{"InstanceCount":3,"InstanceGroupType":"CORE","InstanceType":"m3.xlarge","Name":"Core Instance Group"},'\
'{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"m3.xlarge","Name":"Master Instance Group"}]' \
--configurations '[{"Classification":"capacity-scheduler",'\
'"Properties":{"yarn.scheduler.capacity.resource-calculator":'\
'"org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"}},'\
'{"Classification":"spark","Properties":{"maximizeResourceAllocation":"true"}},'\
'{"Classification":"spark-defaults","Properties":{'\
'"spark.dynamicAllocation.enabled":"true","spark.executor.instances":"0",'\
'"spark.default.parallelism":"96"}}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-2X7O39SSE7T7K' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.164.123",'\
'"--name","4Xm4.xlarge_parallel96",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4Xm4.xlarge_parallel96"}]' \
--profile brian --region us-east-1


##### May 27th
aws emr create-cluster --applications Name=Ganglia Name=Spark \
--ec2-attributes '{"KeyName":"dage_brian","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-3402686c"}' \
--service-role EMR_DefaultRole --enable-debugging --release-label emr-4.6.0 \
--log-uri 's3n://aws-logs-255141198570-us-east-1/elasticmapreduce/' --name 'cluster1' \
--instance-groups \
'[{"InstanceCount":3,"InstanceGroupType":"CORE","InstanceType":"m3.xlarge","Name":"Core Instance Group"},'\
'{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"m3.xlarge","Name":"Master Instance Group"}]' \
--configurations '[{"Classification":"capacity-scheduler",'\
'"Properties":{"yarn.scheduler.capacity.resource-calculator":'\
'"org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"}},'\
'{"Classification":"spark","Properties":{"maximizeResourceAllocation":"true"}},'\
'{"Classification":"spark-defaults","Properties":{'\
'"spark.dynamicAllocation.enabled":"false","spark.executor.instances":"3"}}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1VZUN8FMEBNS2' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.152.161.60",'\
'"--name","noDynamicAllocation_3instances",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"noDynamicAllocation_3instances"}]' \
--profile brian --region us-east-1

aws emr create-cluster --applications Name=Ganglia Name=Spark \
--ec2-attributes '{"KeyName":"dage_brian","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-3402686c"}' \
--service-role EMR_DefaultRole --enable-debugging --release-label emr-4.6.0 \
--log-uri 's3n://aws-logs-255141198570-us-east-1/elasticmapreduce/' --name 'cluster1' \
--instance-groups \
'[{"InstanceCount":4,"InstanceGroupType":"CORE","InstanceType":"m3.xlarge","Name":"Core Instance Group"},'\
'{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"m3.xlarge","Name":"Master Instance Group"}]' \
--configurations '[{"Classification":"capacity-scheduler",'\
'"Properties":{"yarn.scheduler.capacity.resource-calculator":'\
'"org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"}},'\
'{"Classification":"spark","Properties":{'\
'"maximizeResourceAllocation":"true",'\
'"spark.dynamicAllocation.enabled":"false",'\
'"spark.executor.instances":"4"}}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1JHL53RSCT1L5' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.165.220.51",'\
'"--name","noDynamicAllocation_4instances",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"noDynamicAllocation_4instances"}]' \
--profile brian --region us-east-1


aws emr add-steps --cluster-id 'j-1JHL53RSCT1L5' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","5",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.165.220.51",'\
'"--name","noDynamicAllocation_5instances",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"noDynamicAllocation_5instances"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1JHL53RSCT1L5' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","2",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.165.220.51",'\
'"--name","noDynamicAllocation_5instances",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"noDynamicAllocation_5instances"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1JHL53RSCT1L5' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","3",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.165.220.51",'\
'"--name","noDynamicAllocation_5instances",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"noDynamicAllocation_5instances"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1JHL53RSCT1L5' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.165.220.51",'\
'"--name","noDynamicAllocation_5instances",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"noDynamicAllocation_5instances"}]' \
--profile brian --region us-east-1


####June 1st
aws emr create-cluster --applications Name=Ganglia Name=Spark \
--ec2-attributes '{"KeyName":"dage_brian","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-3402686c"}' \
--service-role EMR_DefaultRole --enable-debugging --release-label emr-4.6.0 \
--log-uri 's3n://aws-logs-255141198570-us-east-1/elasticmapreduce/' --name 'cluster1' \
--instance-groups \
'[{"InstanceCount":5,"InstanceGroupType":"CORE","InstanceType":"m3.xlarge","Name":"Core Instance Group"},'\
'{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"m3.xlarge","Name":"Master Instance Group"}]' \
--configurations '[{"Classification":"capacity-scheduler",'\
'"Properties":{"yarn.scheduler.capacity.resource-calculator":'\
'"org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"}},'\
'{"Classification":"spark","Properties":{'\
'"maximizeResourceAllocation":"true",'\
'"spark.dynamicAllocation.enabled":"false",'\
'"spark.executor.instances":"4"}}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3DSV6VFQZ5YX' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","5",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.91.30.222",'\
'"--name","noDynamicAllocation_5instances",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"noDynamicAllocation_5instances"}]' \
--profile brian --region us-east-1


aws emr add-steps --cluster-id 'j-3DSV6VFQZ5YX' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","5",'\
'"--driver-memory","1000M",'\
'"--driver-cores","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.91.30.222",'\
'"--name","noDynamicAllocation_5instances",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"noDynamicAllocation_5instances"}]' \
--profile brian --region us-east-1


aws emr add-steps --cluster-id 'j-3DSV6VFQZ5YX' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","9",'\
'"--executor-memory","4829M",'\
'"--executor-cores","4",'\
'"--driver-memory","4829M",'\
'"--driver-cores","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.91.30.222",'\
'"--name","noDynamicAllocation_5instances",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"noDynamicAllocation_5instances"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3DSV6VFQZ5YX' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","11",'\
'"--executor-memory","4829M",'\
'"--executor-cores","4",'\
'"--driver-memory","4829M",'\
'"--driver-cores","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.91.30.222",'\
'"--name","11_executors",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"11_executors"}]' \
--profile brian --region us-east-1


####June 2nd
aws emr create-cluster --applications Name=Ganglia Name=Spark \
--ec2-attributes '{"KeyName":"dage_brian","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-3402686c"}' \
--service-role EMR_DefaultRole --enable-debugging --release-label emr-4.6.0 \
--log-uri 's3n://aws-logs-255141198570-us-east-1/elasticmapreduce/' --name '5*m4.xlarge' \
--instance-groups \
'[{"InstanceCount":5,"InstanceGroupType":"CORE","InstanceType":"m4.xlarge","Name":"Core Instance Group"},'\
'{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"m4.xlarge","Name":"Master Instance Group"}]' \
--configurations '[{"Classification":"capacity-scheduler",'\
'"Properties":{"yarn.scheduler.capacity.resource-calculator":'\
'"org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"}},'\
'{"Classification":"spark","Properties":{'\
'"maximizeResourceAllocation":"true",'\
'"spark.dynamicAllocation.enabled":"false",'\
'"spark.executor.instances":"5"}}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"June_2nd"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"June_2nd"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","9",'\
'"--executor-memory","5178M",'\
'"--executor-cores","4",'\
'"--driver-memory","5178M",'\
'"--driver-cores","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"June_2nd"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","7",'\
'"--executor-memory","5178M",'\
'"--executor-cores","4",'\
'"--driver-memory","5178M",'\
'"--driver-cores","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"June_2nd"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","5",'\
'"--executor-memory","5178M",'\
'"--executor-cores","4",'\
'"--driver-memory","5178M",'\
'"--driver-cores","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"June_2nd"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","8",'\
'"--executor-memory","5178M",'\
'"--executor-cores","4",'\
'"--driver-memory","5178M",'\
'"--driver-cores","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"June_2nd"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"--executor-memory","5178M",'\
'"--executor-cores","4",'\
'"--driver-memory","5178M",'\
'"--driver-cores","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"June_2nd"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","6",'\
'"--executor-memory","5178M",'\
'"--executor-cores","4",'\
'"--driver-memory","5178M",'\
'"--driver-cores","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"June_2nd"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","3",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"3exe"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","2",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"2exe"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","1",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"2exe"}]' \
--profile brian --region us-east-1


aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--parallelism","80",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_80para"}]' \
--profile brian --region us-east-1


aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--parallelism","64",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_64para"}]' \
--profile brian --region us-east-1


aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--parallelism","32",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_32para"}]' \
--profile brian --region us-east-1


aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--parallelism","16",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_16para"}]' \
--profile brian --region us-east-1


aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--parallelism","128",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_128para"}]' \
--profile brian --region us-east-1


aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","5",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"5exe"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","6",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"6exe"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","7",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"7exe"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-3C58PVKFY5Z85' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","8",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","52.87.184.112",'\
'"--name","June_2nd",'\
'"--flip-allele",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"8exe"}]' \
--profile brian --region us-east-1


####### June 3rd
aws emr create-cluster --applications Name=Ganglia Name=Spark \
--ec2-attributes '{"KeyName":"dage_brian","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-3402686c"}' \
--service-role EMR_DefaultRole --enable-debugging --release-label emr-4.6.0 \
--log-uri 's3n://aws-logs-255141198570-us-east-1/elasticmapreduce/' --name '5*m4.xlarge' \
--instance-groups \
'[{"InstanceCount":5,"InstanceGroupType":"CORE","InstanceType":"m4.xlarge","Name":"Core Instance Group"},'\
'{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"m4.xlarge","Name":"Master Instance Group"}]' \
--configurations '[{"Classification":"capacity-scheduler",'\
'"Properties":{"yarn.scheduler.capacity.resource-calculator":'\
'"org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"}},'\
'{"Classification":"spark","Properties":{'\
'"maximizeResourceAllocation":"true",'\
'"spark.dynamicAllocation.enabled":"false",'\
'"spark.executor.instances":"5"}}]' \
--profile brian --region us-east-1

#repeat the following 4 steps 3 times
aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","1",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","16",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"1exe_16para"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","2",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","32",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"2exe_32para"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","3",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","48",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"3exe_48para"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","64",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_64para"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","6",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","96",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"6exe_96para"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","5",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","80",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"5exe_80para"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","7",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","112",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"7exe_112para"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","8",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","128",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"8exe_128para"}]' \
--profile brian --region us-east-1




aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"--executor-cores","6",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","64",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_6vcores"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"--executor-cores","6",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","48",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_6vcores_48para"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"--executor-cores","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","32",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_4vcores_32para"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"--executor-cores","2",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","16",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_2vcores_16para"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"--executor-memory","7767M",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","64",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_7767MB"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"--executor-memory","5178M",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","64",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_5178MB"}]' \
--profile brian --region us-east-1

aws emr add-steps --cluster-id 'j-1DW0PKAXQFY8Q' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"--executor-memory","2589M",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.175.253.85",'\
'"--name","June_3rd",'\
'"--parallelism","64",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_2589MB"}]' \
--profile brian --region us-east-1
#end of repeat


####### June 4th
aws emr create-cluster --applications Name=Ganglia Name=Spark \
--ec2-attributes '{"KeyName":"dage_brian","InstanceProfile":"EMR_EC2_DefaultRole","AvailabilityZone":"us-east-1a"}' \
--service-role EMR_DefaultRole --enable-debugging --release-label emr-4.6.0 \
--log-uri 's3n://aws-logs-255141198570-us-east-1/elasticmapreduce/' --name '5*r3.xlarge' \
--instance-groups \
'[{"InstanceCount":5,"InstanceGroupType":"CORE","InstanceType":"r3.xlarge","Name":"Core Instance Group"},'\
'{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"r3.xlarge","Name":"Master Instance Group"}]' \
--configurations '[{"Classification":"capacity-scheduler",'\
'"Properties":{"yarn.scheduler.capacity.resource-calculator":'\
'"org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"}},'\
'{"Classification":"spark","Properties":{'\
'"maximizeResourceAllocation":"true",'\
'"spark.dynamicAllocation.enabled":"false",'\
'"spark.executor.instances":"5"}}]' \
--profile brian --region us-east-1

#repeat 3 times
aws emr add-steps --cluster-id 'j-JQ00XSZLNCQA' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.85.165.89",'\
'"--name","June_4th",'\
'"--parallelism","64",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe"}]' \
--profile brian --region us-east-1




aws emr create-cluster --applications Name=Ganglia Name=Spark \
--ec2-attributes '{"KeyName":"dage_brian","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-e6481790"}' \
--service-role EMR_DefaultRole --enable-debugging --release-label emr-4.6.0 \
--log-uri 's3n://aws-logs-255141198570-us-east-1/elasticmapreduce/' --name '5*m4.xlarge' \
--instance-groups \
'[{"InstanceCount":5,"InstanceGroupType":"CORE","InstanceType":"m4.xlarge","Name":"Core Instance Group"},'\
'{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"m4.xlarge","Name":"Master Instance Group"}]' \
--configurations '[{"Classification":"capacity-scheduler",'\
'"Properties":{"yarn.scheduler.capacity.resource-calculator":'\
'"org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"}},'\
'{"Classification":"spark","Properties":{'\
'"maximizeResourceAllocation":"true",'\
'"spark.dynamicAllocation.enabled":"false",'\
'"spark.executor.instances":"5"}}]' \
--profile brian --region us-east-1


aws emr add-steps --cluster-id 'j-1S2EIFPR64NT7' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.85.165.89",'\
'"--name","June_4th",'\
'"--parallelism","64",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_m4.xlarge"}]' \
--profile brian --region us-east-1





aws emr create-cluster --applications Name=Ganglia Name=Spark \
--ec2-attributes '{"KeyName":"dage_brian","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-e6481790"}' \
--service-role EMR_DefaultRole --enable-debugging --release-label emr-4.6.0 \
--log-uri 's3n://aws-logs-255141198570-us-east-1/elasticmapreduce/' --name '5*m3.xlarge' \
--instance-groups \
'[{"InstanceCount":5,"InstanceGroupType":"CORE","InstanceType":"m3.xlarge","Name":"Core Instance Group"},'\
'{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"m3.xlarge","Name":"Master Instance Group"}]' \
--configurations '[{"Classification":"capacity-scheduler",'\
'"Properties":{"yarn.scheduler.capacity.resource-calculator":'\
'"org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"}},'\
'{"Classification":"spark","Properties":{'\
'"maximizeResourceAllocation":"true",'\
'"spark.dynamicAllocation.enabled":"false",'\
'"spark.executor.instances":"5"}}]' \
--profile brian --region us-east-1

#repeat 3 times
aws emr add-steps --cluster-id 'j-WBBXURCDBAVX' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.85.165.89",'\
'"--name","June_4th",'\
'"--parallelism","64",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_m3.xlarge"}]' \
--profile brian --region us-east-1






aws emr create-cluster --applications Name=Ganglia Name=Spark \
--ec2-attributes '{"KeyName":"dage_brian","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-e6481790"}' \
--service-role EMR_DefaultRole --enable-debugging --release-label emr-4.6.0 \
--log-uri 's3n://aws-logs-255141198570-us-east-1/elasticmapreduce/' --name '5*c3.2xlarge' \
--instance-groups \
'[{"InstanceCount":5,"InstanceGroupType":"CORE","InstanceType":"c3.2xlarge","Name":"Core Instance Group"},'\
'{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"c3.xlarge","Name":"Master Instance Group"}]' \
--configurations '[{"Classification":"capacity-scheduler",'\
'"Properties":{"yarn.scheduler.capacity.resource-calculator":'\
'"org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"}},'\
'{"Classification":"spark","Properties":{'\
'"maximizeResourceAllocation":"true",'\
'"spark.dynamicAllocation.enabled":"false",'\
'"spark.executor.instances":"5"}}]' \
--profile brian --region us-east-1

#repeat 3 times
aws emr add-steps --cluster-id 'j-3896YAVSMIURX' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.85.165.89",'\
'"--name","June_4th",'\
'"--parallelism","64",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_c3.2xlarge"}]' \
--profile brian --region us-east-1


#won't work
aws emr create-cluster --applications Name=Ganglia Name=Spark \
--ec2-attributes '{"KeyName":"dage_brian","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-e6481790"}' \
--service-role EMR_DefaultRole --enable-debugging --release-label emr-4.6.0 \
--log-uri 's3n://aws-logs-255141198570-us-east-1/elasticmapreduce/' --name '5*c3.2xlarge' \
--instance-groups \
'[{"InstanceCount":5,"InstanceGroupType":"CORE","InstanceType":"c3.2xlarge","Name":"Core Instance Group"},'\
'{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"c3.xlarge","Name":"Master Instance Group"}]' \
--configurations '[{"Classification":"capacity-scheduler",'\
'"Properties":{"yarn.scheduler.capacity.resource-calculator":'\
'"org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"}},'\
'{"Classification":"spark","Properties":{'\
'"maximizeResourceAllocation":"true",'\
'"spark.dynamicAllocation.enabled":"false",'\
'"spark.executor.instances":"5"}},'\
'{"Classification":"yarn-site","Properties":{'\
'"yarn.scheduler.maximum-allocation-vcores":"16"}}]' \
--profile brian --region us-east-1

#repeat 3 times, failed
aws emr add-steps --cluster-id 'j-26OYVVXXXX9K7' \
--steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","Main",'\
'"--num-executors","4",'\
'"--executor-cores","16",'\
'"s3://dage_brian/jars/Simple_Project-assembly-0.0.1.jar",'\
'"-i","s3://neighbor_study/clean-merged-neighbor.vcf",'\
'"-o","s3://neighbor_study/output/",'\
'"--export-missing-keys","s3://neighbor_study/output/miss/",'\
'"-h","54.85.165.89",'\
'"--name","June_4th",'\
'"--parallelism","128",'\
'"--aws-access-key-id","MyKey",'\
'"--aws-secret-access-key","MyValue"],'\
'"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar",'\
'"Properties":"","Name":"4exe_c3.2xlarge_16cores"}]' \
--profile brian --region us-east-1