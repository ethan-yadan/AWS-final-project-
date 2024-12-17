#!/bin/bash

# Script to launch an AWS EC2 instance

# Variables
AMI_ID="ami-0e2c8caa4b6378d8c"           
INSTANCE_TYPE="t2.micro"                
TAG_KEY_EC2="Name"                      
TAG_VALUE_EC2="MyProjectEC2Instance"    


# Launch the EC2 Instance
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --count 1 \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --subnet-id "$SUBNET_ID" \
  --security-group-ids "$SECURITY_GROUP_ID" \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=$TAG_KEY_EC2,Value=$TAG_VALUE_EC2}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "EC2 instance launched successfully with ID: $INSTANCE_ID"

# Retrieve EC2 instance details
INSTANCE_DETAILS=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress]' \
  --output table)

echo "$INSTANCE_DETAILS"
