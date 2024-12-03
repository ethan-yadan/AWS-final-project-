# AWS-final-project
AWS Final Project - Technion DevOps

![AWS Arch](course_HA_example.png)

## Steps 

- install and update standard python and debian linux
- install and update aws cli on your linux debian vm
- aws configure your account to your vm (aws access key ID, aws secret access key, aws region name and output format)

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

- 
