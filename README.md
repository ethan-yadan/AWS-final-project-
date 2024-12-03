# AWS-final-project
AWS Final Project - Technion DevOps

![AWS Arch](course_HA_example.png)

## Steps 

- install and update standard python and debian linux
- install and update aws cli on your linux debian vm
- aws configure your account to your vm (aws access key ID, aws secret access key, aws region name and output format)
- us-east-1 ubuntu 24.04 LTS ami : ami-0932ffb346ea84d48
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

- aws ec2 describe-key-pairs
- aws ec2 run-instances --image-id ami-0932ffb346ea84d48 --instance-type t2.micro --count 1 --key-name key-0ffa0d1a7a27b1623
