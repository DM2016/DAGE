#!/usr/bin/env bash
#./cassandra_boot.sh /etc/cassandra/default.conf/cassandra.yaml 172.31.17.119 "172.31.17.119"
echo "Configuring cassandra.yaml"
cassandra_yaml_path=/etc/cassandra/conf/cassandra.yaml
cassandra_yaml_default_path=/etc/cassandra/default.conf/cassandra.yaml
sudo python /home/ec2-user/cassandra_setup.py $cassandra_yaml_path $1 $2
sudo python /home/ec2-user/cassandra_setup.py $cassandra_yaml_default_path $1 $2
sudo service cassandra start
#sudo tail -f /var/log/cassandra/system.log