#!/bin/bash 

set -e  # Exit script if any error occurs
set -x  # Enable debugging, prints each command as it's executed

# Set variables 
VPC_CIDR="10.0.0.0/16" # This VPC will have IP's ranging from 10.0.0.0 to 10.0.255.255
SUBNET_CIDR="10.0.1.0/24" # This Subnet will have IP's ranging from 10.0.1.0 to 10.0.1.255
REGION="us-east-1" # Sets the AWS desired region, where VPC and related resources wil be created  

SECURITY_GROUP_NAME="my-security-group"
SECURITY_GROUP_DESC="Security group for my VPC"
# Virtual firewall to control inbound and outbound traffic for associated resources

TAG_KEY="Name"
TAG_VALUE="MyVPCSetup"
# Tags for categorizing and managing resources 

KEY_NAME="my-keypair" # Key pair name to be used to access to the EC2 instance
KEY_FILE="${KEY_NAME}.pem" # Private key file associated with the key pair 
AMI_ID="ami-0c02fb55956c7d316" # Amazon Machine Image (AMI), Replace with the desired AMI ID, relevant to your region and requirements 
INSTANCE_TYPE="t2.micro" # EC2 instance type to be launched 

TAG_KEY_EC2="Name"
TAG_VALUE_EC2="MyEC2Instance"
# Tags for categorizing and managing resources


# Create a VPC
function create_vpc(){
    echo "Creating VPC..."
    VPC_ID=$(aws ec2 create-vpc --cidr-block "$VPC_CIDR" --region "$REGION" --query 'Vpc.VpcId' --output text 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo "Failed to tag VPC"
        return 1 
    fi 

    echo "VPC created with ID: $VPC_ID"

    # Add a name tag to the VPC
    echo "Tagging VPC..."
    aws ec2 create-tags --resources "$VPC_ID" --tags Key="$TAG_KEY",Value="$TAG_VALUE" --region "$REGION"
    if [ $? -ne 0 ]; then   
        echo "Failed to tag VPC" 
        return 1
    fi 

    echo "VPC tagged with $TAG_KEY=$TAG_VALUE"
}


# Create a Subnet
function create_subnet(){
    echo "Creating Subnet..."

    # Check if VPC_ID is set
    if [ -z "$VPC_ID" ]; then 
        echo "Error: VPC_ID is not set. Please ensure you have created a VPC before creating a subnet" 
        return 1
    fi

    # Create the subnet 
    SUBNET_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "$SUBNET_CIDR" --region "$REGION" --query 'Subnet.SubnetId' --output text 2>/dev/null) 

    if [ $? -ne 0 ]; then
        echo "Faild to create subnet. Please check your AWS CLI configuration ane permissions"
        return 1
    fi 

    echo "Subnet created with ID: $SUBNET_ID"

    # Add a name tag to the Subnet
    echo "Tagging Subnet..."
    aws ec2 create-tags --resources "$SUBNET_ID" --tags Key="$TAG_KEY",Value="Subnet-$TAG_VALUE" --region "$REGION"

    if [ $? -ne 0 ]; then
        echo "Failed to tag subnet"
        return 1
    fi 

    echo "Subnet tagged with $TAG_KEY=Subnet-$TAG_VALUE"
}

# Create an Internet Gateway
function create_gateway(){
    echo "Creating an Internet Gateway..."
}
# Call functions 
create_vpc
create_subnet
create_gateway


