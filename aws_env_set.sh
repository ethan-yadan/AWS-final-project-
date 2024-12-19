#!/bin/bash

############### Start of Secure Header ###############
# Created by: Eitan Yadan                            #
# Purpose: creates aws environment for ec2           #
# Version: 1.0.5                                     #
# Date: 17.12.2024                                   #
set -o errexit                                       #
set -o pipefail                                      #
set -o nounset                                       #
set -x                                               #
############### End of Secure Header #################


# AWS Environment Variables Setup 
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR="10.0.1.0/24"
REGION="us-east-1"
TAG_KEY="Name"
TAG_VALUE="MyProjectVPC"
SECURITY_GROUP_NAME="my-project-security-group"
SECURITY_GROUP_DESC="Project security group for my VPC"


# 1. AWS VPC Cretaion and Tags
VPC_ID=$(aws ec2 create-vpc --cidr-block "$VPC_CIDR" --region "$REGION" --query 'Vpc.VpcId' --output text)
echo "VPC created with ID: $VPC_ID"

aws ec2 create-tags --resources "$VPC_ID" --tags Key="$TAG_KEY",Value="$TAG_VALUE" --region "$REGION"
echo "VPC tagged with $TAG_KEY=$TAG_VALUE"


# 2. AWS Subnet Creation and Tagging
SUBNET_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "$SUBNET_CIDR" --region "$REGION" --query 'Subnet.SubnetId' --output text) 
echo "Subnet created with ID: $SUBNET_ID"

aws ec2 create-tags --resources "$SUBNET_ID" --tags Key="$TAG_KEY",Value="Subnet-$TAG_VALUE" --region "$REGION"
echo "Subnet tagged with $TAG_KEY=Subnet-$TAG_VALUE"


# 3. AWS Internet Gateway Creation and Tagging
IGW_ID=$(aws ec2 create-internet-gateway --region "$REGION" --query 'InternetGateway.InternetGatewayId' --output text)
echo "Internet Gateway created successfully in region "$REGION" with ID: "$IGW_ID" "
    
aws ec2 attach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" --region "$REGION" 
echo "Internet Gateway $IGW_ID successfully attached to VPC "$VPC_ID" in region "$REGION"."
    

# 4. AWS Route Table and Associate to Subnet 
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --region "$REGION" --query 'RouteTable.RouteTableId' --output text)
echo "Route Table created with ID: "$ROUTE_TABLE_ID""
   
aws ec2 create-route --route-table-id "$ROUTE_TABLE_ID" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW_ID" --region "$REGION" 
echo "Route successfully added to Route Table "$ROUTE_TABLE_ID" "
    
aws ec2 associate-route-table --route-table-id "$ROUTE_TABLE_ID" --subnet-id "$SUBNET_ID" --region "$REGION" 
echo "Subnet "$SUBNET_ID" successfully associated with Route Table "$ROUTE_TABLE_ID" "


# 5. AWS Security Group Creation and Ingress Roles 
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name "$SECURITY_GROUP_NAME" --description "$SECURITY_GROUP_DESC" --vpc-id "$VPC_ID" --region "$REGION" --query 'GroupId' --output text)
echo "Security Group created successfully with ID: "$SECURITY_GROUP_ID" "
aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0 --region "$REGION"
aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 --region "$REGION"
aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 443 --cidr 0.0.0.0/0 --region "$REGION"


# 6. Summary 
echo " **** AWS Environment Creation Status **** "
echo "-------------------------------------------"
echo "VPC ID: "$VPC_ID" "
echo "Subnet ID: "$SUBNET_ID" "
echo "Internet Gateway ID: "$IGW_ID" "
echo "Route Table ID: "$ROUTE_TABLE_ID" "
echo "Security Group ID: "$SECURITY_GROUP_ID" "
echo "-------------------------------------------"


# 7. AWS Key Pair Creation and Permissions
KEY_NAME="my-project-keypair"
KEY_FILE="${KEY_NAME}.pem"

aws ec2 create-key-pair --key-name "$KEY_NAME" --query 'KeyMaterial' --output text > "$KEY_FILE" 
echo "Key pair "$KEY_NAME" created successfully and saved as "$KEY_FILE" "
chmod 400 "$KEY_FILE"


# 8. AWS EC2 Instances Creation and Launching 
AMI_ID="ami-0e2c8caa4b6378d8c"
INSTANCE_TYPE="t2.micro" 
TAG_KEY_EC2="Name"
TAG_VALUE_EC2="Jenkins_EC2"
TAG_VALUE_EC2w="Nginx_EC2"

INSTANCE_ID1=$(aws ec2 run-instances --image-id "$AMI_ID" --count 1 --instance-type "$INSTANCE_TYPE" --key-name "$KEY_NAME" --subnet-id "$SUBNET_ID" --security-group-ids "$SECURITY_GROUP_ID" --associate-public-ip-address --tag-specifications "ResourceType=instance,Tags=[{Key="$TAG_KEY_EC2",Value="$TAG_VALUE_EC2"}]" --query 'Instances[0].InstanceId' --output text)

INSTANCE_ID2=$(aws ec2 run-instances --image-id "$AMI_ID" --count 1 --instance-type "$INSTANCE_TYPE" --key-name "$KEY_NAME" --subnet-id "$SUBNET_ID" --security-group-ids "$SECURITY_GROUP_ID" --associate-public-ip-address --tag-specifications "ResourceType=instance,Tags=[{Key="$TAG_KEY_EC2",Value="$TAG_VALUE_EC2w"}]" --query 'Instances[0].InstanceId' --output text)

echo "EC2 instance launched successfully with ID: "$INSTANCE_ID1" "
echo "EC2 instance launched successfully with ID: "$INSTANCE_ID2" "

INSTANCE_DETAILS1=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID1" --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress]' --output table )
INSTANCE_DETAILS2=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID2" --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress]' --output table )

echo "$INSTANCE_DETAILS1"
echo "$INSTANCE_DETAILS2"


# 9. Check EC2 Instances Status 
aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[].Instances[].{InstanceId: InstanceId, PublicIpAddress: PublicIpAddress, PrivateIpAddress: PrivateIpAddress, State: State.Name, InstanceType: InstanceType}' --output table
