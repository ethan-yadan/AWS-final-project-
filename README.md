# AWS-final-project
AWS Final Project - Technion DevOps

![AWS Arch](course_HA_example.png)

## Steps 

- install and update standard python and debian linux
- install and update aws cli on your linux debian vm
- aws configure your account to your vm (aws access key ID, aws secret access key, aws region name and output format)
- us-east-1 ubuntu 24.04 LTS ami : ami-087c17d1fe0178315
- get the key pair id to build ec2 machine 

## Installation 

### Install and configure AWS cli 

- sudo apt update
- sudo apt install awscli
- aws --version
- aws configure
- aws s3 ls --profile my-profile
- sudo apt update && sudo apt upgrade awscli
- cat ~/.aws/credentials
- aws sts get-caller-identity (this will confirm that you're connected to your aws account)

### Create an aws environment 
!!!! pay attention, you have to run all the commands in alex's post in telegram, meanning to create an entire architecture to be able to connect to this machine from the world
what i did in class was to create an EC2 but without all of the configuration (vpc, subnet, cid ... etc) it's not possible to connect from the world to the EC2 !!!!


- aws ec2 create-key-pair --key-name EC2KeyPair --query "KeyMaterial" --output text > EC2KeyPair.pem
- chmod 400 EC2KeyPair.pem
- aws ec2 describe-key-pairs
- !!!!! need to create a subnet, check instructions !!!!!
- !!!!! need to create a VPC, check instructions !!!!!!
- aws ec2 run-instances --image-id ami-087c17d1fe0178315 --count 1 --instance-type t2.micro --key-name EC2KeyPair  --security-group-ids sg-092c59c4855a0a12d --subnet-id subnet-068f7b1d93da3fc7e --associate-public-ip-address --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=Demo-EC2}]'
-  ssh -i "EC2KeyPair.pem" ubuntu@3.92.141.150 -v ## deppends on the used image, you can see the default user on the console ## to connect to EC2 need to use the public id (not private ip) ##
