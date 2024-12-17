#!/bin/bash

# AWS Environment Setup Script

# Variables
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR="10.0.1.0/24"
REGION="us-east-1"
TAG_KEY="Name"
TAG_VALUE="MyProjectVPC"
SECURITY_GROUP_NAME="my-project-security-group"
SECURITY_GROUP_DESC="Project security group for my VPC"

KEY_NAME="my-project-keypair"
KEY_FILE="${KEY_NAME}.pem"

# Function to check if a command was successful
function check_success {
  if [ $? -ne 0 ]; then
    echo "Error: $1 failed. Exiting script."
    exit 1
  fi
}

echo "Starting AWS environment setup in region: $REGION"

# 1. Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block "$VPC_CIDR" --region "$REGION" --query 'Vpc.VpcId' --output text)
check_success "VPC creation"
echo "VPC created with ID: $VPC_ID"

# 2. Tag VPC
aws ec2 create-tags --resources "$VPC_ID" --tags Key="$TAG_KEY",Value="$TAG_VALUE" --region "$REGION"
check_success "Tagging VPC"
echo "VPC tagged with $TAG_KEY=$TAG_VALUE"

# 3. Create Subnet
SUBNET_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "$SUBNET_CIDR" --region "$REGION" --query 'Subnet.SubnetId' --output text)
check_success "Subnet creation"
echo "Subnet created with ID: $SUBNET_ID"

# 4. Tag Subnet
aws ec2 create-tags --resources "$SUBNET_ID" --tags Key="$TAG_KEY",Value="Subnet-$TAG_VALUE" --region "$REGION"
check_success "Tagging Subnet"
echo "Subnet tagged with $TAG_KEY=Subnet-$TAG_VALUE"

# 5. Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway --region "$REGION" --query 'InternetGateway.InternetGatewayId' --output text)
check_success "Internet Gateway creation"
echo "Internet Gateway created with ID: $IGW_ID"

# 6. Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" --region "$REGION"
check_success "Attaching Internet Gateway"
echo "Internet Gateway $IGW_ID attached to VPC $VPC_ID"

# 7. Create Route Table
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --region "$REGION" --query 'RouteTable.RouteTableId' --output text)
check_success "Route Table creation"
echo "Route Table created with ID: $ROUTE_TABLE_ID"

# 8. Create Route
aws ec2 create-route --route-table-id "$ROUTE_TABLE_ID" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW_ID" --region "$REGION"
check_success "Creating Route"
echo "Route to 0.0.0.0/0 added to Route Table $ROUTE_TABLE_ID"

# 9. Associate Route Table with Subnet
aws ec2 associate-route-table --route-table-id "$ROUTE_TABLE_ID" --subnet-id "$SUBNET_ID" --region "$REGION"
check_success "Associating Route Table with Subnet"
echo "Route Table $ROUTE_TABLE_ID associated with Subnet $SUBNET_ID"

# 10. Create Security Group
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name "$SECURITY_GROUP_NAME" --description "$SECURITY_GROUP_DESC" --vpc-id "$VPC_ID" --region "$REGION" --query 'GroupId' --output text)
check_success "Security Group creation"
echo "Security Group created with ID: $SECURITY_GROUP_ID"

# 11. Add Ingress Rules to Security Group
aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0 --region "$REGION"
check_success "Allowing SSH (22) ingress"

aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 --region "$REGION"
check_success "Allowing HTTP (80) ingress"

aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 443 --cidr 0.0.0.0/0 --region "$REGION"
check_success "Allowing HTTPS (443) ingress"

# 12. Create Key Pair
if [ ! -f "$KEY_FILE" ]; then
  aws ec2 create-key-pair --key-name "$KEY_NAME" --query 'KeyMaterial' --output text > "$KEY_FILE"
  check_success "Key Pair creation"
  chmod 400 "$KEY_FILE"
  echo "Key Pair '$KEY_NAME' created successfully and saved as '$KEY_FILE'."
else
  echo "Key Pair file '$KEY_FILE' already exists. Skipping creation."
fi

# Summary
echo "-------------------------------------------"
echo "AWS Environment Setup Complete:"
echo "VPC ID: $VPC_ID"
echo "Subnet ID: $SUBNET_ID"
echo "Internet Gateway ID: $IGW_ID"
echo "Route Table ID: $ROUTE_TABLE_ID"
echo "Security Group ID: $SECURITY_GROUP_ID"
echo "Key Pair File: $KEY_FILE"
echo "-------------------------------------------"

exit 0
