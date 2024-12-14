#!/bin/bash

 

# Set variables

VPC_CIDR="10.0.0.0/16"

SUBNET_CIDR="10.0.1.0/24"

REGION="us-east-1"

SECURITY_GROUP_NAME="my-security-group"

SECURITY_GROUP_DESC="Security group for my VPC"

TAG_KEY="Name"

TAG_VALUE="MyVPCSetup"

 

 

KEY_NAME="my-keypair"

KEY_FILE="${KEY_NAME}.pem"

AMI_ID="ami-0c02fb55956c7d316" # Replace with the desired AMI ID

INSTANCE_TYPE="t2.micro"

TAG_KEY_EC2="Name"

TAG_VALUE_EC2="MyEC2Instance"

 

 

# Create a VPC

echo "Creating VPC..."

VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --region $REGION --query 'Vpc.VpcId' --output text)

echo "VPC created with ID: $VPC_ID"

 

# Add a tag to the VPC

aws ec2 create-tags --resources $VPC_ID --tags Key=$TAG_KEY,Value=$TAG_VALUE --region $REGION

 

# Create a subnet

echo "Creating Subnet..."

SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR --region $REGION --query 'Subnet.SubnetId' --output text)

echo "Subnet created with ID: $SUBNET_ID"

 

# Create an Internet Gateway

echo "Creating Internet Gateway..."

IGW_ID=$(aws ec2 create-internet-gateway --region $REGION --query 'InternetGateway.InternetGatewayId' --output text)

echo "Internet Gateway created with ID: $IGW_ID"

 

# Attach the Internet Gateway to the VPC

echo "Attaching Internet Gateway to VPC..."

aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region $REGION

 

# Create a Route Table

echo "Creating Route Table..."

ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --region $REGION --query 'RouteTable.RouteTableId' --output text)

echo "Route Table created with ID: $ROUTE_TABLE_ID"

 

# Add a route to the Route Table

echo "Adding Route to Route Table..."

aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --region $REGION

 

# Associate the Subnet with the Route Table

echo "Associating Subnet with Route Table..."

aws ec2 associate-route-table --route-table-id $ROUTE_TABLE_ID --subnet-id $SUBNET_ID --region $REGION

 

# Create a Security Group

echo "Creating Security Group..."

SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name $SECURITY_GROUP_NAME --description "$SECURITY_GROUP_DESC" --vpc-id $VPC_ID --region $REGION --query 'GroupId'>

echo "Security Group created with ID: $SECURITY_GROUP_ID"

 

# Add inbound rules to the Security Group

echo "Adding Inbound Rules to Security Group..."

aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $REGION

aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION

aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 443 --cidr 0.0.0.0/0 --region $REGION

 

 

echo "All resources created successfully!"

echo "VPC ID: $VPC_ID"

echo "Subnet ID: $SUBNET_ID"

echo "Internet Gateway ID: $IGW_ID"

echo "Route Table ID: $ROUTE_TABLE_ID"

 

# Generate a new key pair

echo "Creating Key Pair..."

aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text > $KEY_FILE

 

# Set permissions for the key file

echo "Setting permissions for the key file..."

chmod 400 $KEY_FILE

echo "Key pair created and saved as $KEY_FILE"

 

# Launch an EC2 instance

echo "Launching EC2 instance..."

INSTANCE_ID=$(aws ec2 run-instances \

    --image-id $AMI_ID \

    --count 1 \

    --instance-type $INSTANCE_TYPE \

    --key-name $KEY_NAME \

    --subnet-id $SUBNET_ID \

    --security-group-ids $SECURITY_GROUP_ID \

    --tag-specifications "ResourceType=instance,Tags=[{Key=$TAG_KEY,Value=$TAG_VALUE}]" \

    --query 'Instances[0].InstanceId' \

    --output text)

 

# Check the instance launch status

if [ -z "$INSTANCE_ID" ]; then

    echo "Error: Failed to launch EC2 instance."

    exit 1

else

    echo "EC2 instance launched successfully with ID: $INSTANCE_ID"

fi

 

# Output the instance details

echo "Fetching instance details..."

aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress]' --output table