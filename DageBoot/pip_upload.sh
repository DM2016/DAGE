#!/usr/bin/env bash
python setup.py install
python setup.py develop
#Probably only one of the two commands above is necessary,
#but I'm too lazy to figure out which....
python setup.py sdist upload # to upload to pypi
subl ~/.aws/credentials

#scp -i ~/.ec2/dage.pem ~/.ec2/dage.pem ec2-user@:~/
#ssh -i ~/.ec2/dage.pem ec2-user@
#sudo pip install dageboot
#aws configure
#dageboot --key-pair dage --key-file ~/.ec2/dage.pem --aws-profile-name default
