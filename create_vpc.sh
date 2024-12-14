#!/bin/bash 

# Set AWS credentials
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="your-region"

# Create a VPC
function create_vpc(){
    echo "Creating VPC..."
    VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --region us-east-1 --query 'Vpc.VpcId' --output text)

    echo "VPC created with ID: $VPC_ID"

    # Add a name tag to the VPC
    echo "Tagging VPC..."
    aws ec2 create-tags --resources $VPC_ID --tags Key=name,Value=myProjectVPC --region us-east-1
    
    echo "VPC tagged with $TAG_KEY=$TAG_VALUE"
}

# call function 
create_vpc
