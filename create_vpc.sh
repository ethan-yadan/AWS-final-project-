#!/bin/bash 

# Set variables 
VPC_CIDR="10.0.0.0/16" # This VPC will have IP's ranging from 10.0.0.0 to 10.0.255.255
REGION="us-east-1" # Sets the AWS desired region, where VPC and related resources wil be created  

TAG_KEY="Name"
TAG_VALUE="MyprojectVPC"
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

# call function 
create_vpc