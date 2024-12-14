# AWS-final-project
AWS Final Project - Technion DevOps

![AWS Logo](aws_logo.png)

The provided script (set_env.sh) is an AWS infrastructure setup script written in Bash. 
It performs the following tasks using the AWS CLI:

- Creates a VPC: A Virtual Private Cloud (VPC) is created with the CIDR block 10.0.0.0/16. It also tags the VPC with a name MyVPCSetup.
- Creates a Subnet: A subnet is created within the VPC with the CIDR block 10.0.1.0/24. The subnet is tagged with a name Subnet-MyVPCSetup.
- Creates an Internet Gateway (IGW): An internet gateway is created and will be attached to the VPC for internet access.
- Attaches the IGW to the VPC: The script attaches the created internet gateway to the VPC, enabling internet connectivity.
- Creates a Route Table: A route table is created, a default route (0.0.0.0/0) is added to route traffic via the internet gateway, and the subnet is associated with this route table.
- Creates a Security Group: A security group is created and configured to allow inbound traffic on ports 22 (SSH), 80 (HTTP), and 443 (HTTPS).
- Generates a Key Pair: An SSH key pair (my-keypair) is created and saved as a .pem file to access EC2 instances later.
- Launches an EC2 Instance: An EC2 instance is launched in the subnet with:
  - specified AMI (ami-0c02fb55956c7d316)
  - instance type (t2.micro)
  - security group
  - key pair
  - The instance is tagged with MyEC2Instance

- Outputs Resource Details: After the resources are created, the script outputs the IDs of the VPC, subnet, internet gateway, route table, security group, and EC2 instance.

Additional Details:

- The script uses set -e to stop execution if any command fails, and set -x to print the commands as they are executed for debugging.
- Error logs are written to /tmp/aws_error.log for better troubleshooting.
- The script includes tagging for better resource management.
- The SSH private key generated for EC2 access has permissions set to 400 to ensure secure access.

![AWS Arch](course_HA_example.png)

## Steps 

- install and update local debian environment
- install and update aws cli on local debian vm
- aws configure and connect your local vm to aws account
- run bash script to create environment in aws (two ec2 instances: nginx webserver & jenkins master)
- check environment created in aws
- connect by ssh from local vm to aws ec2 instances created
- install and configure nginx on instance nginx webserver
- install and configure jenkins on jenkins master instance
- 



## Installation 

### Install and configure AWS cli 

- sudo apt update
- sudo apt install awscli
- aws --version
- aws configure
- add session token (if using a temporary session crediatials) to ~/.aws/credentials (''' nano ~/.aws/credentials ''')
- sudo apt update && sudo apt upgrade awscli
- cat ~/.aws/credentials
- aws sts get-caller-identity (this will confirm that you're connected to your aws account)
- aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].{Instance:InstanceId,State:State.Name,Type:InstanceType,AZ:Placement.AvailabilityZone,PublicIP:PublicIpAddress}" --output table


### Create an aws environment 

- ''' VPC_CIDR="10.0.0.0/16"
      SUBNET_CIDR="10.0.1.0/24"
      REGION="us-east-1"
      TAG_KEY="Name"
      TAG_VALUE="MyProjectVPC"
      SECURITY_GROUP_NAME="my-project-security-group"
      SECURITY_GROUP_DESC="Project security group for my VPC" '''


- ''' VPC_ID=$(aws ec2 create-vpc --cidr-block "$VPC_CIDR" --region "$REGION" --query 'Vpc.VpcId' --output text) '''
- ''' echo "VPC created with ID: $VPC_ID" '''
- ''' aws ec2 create-tags --resources "$VPC_ID" --tags Key="$TAG_KEY",Value="$TAG_VALUE" --region "$REGION" '''
- ''' echo "VPC tagged with $TAG_KEY=$TAG_VALUE" '''
- ''' SUBNET_ID=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "$SUBNET_CIDR" --region "$REGION" --query 'Subnet.SubnetId' --output text) '''
- ''' echo "Subnet created with ID: $SUBNET_ID" '''
- ''' aws ec2 create-tags --resources "$SUBNET_ID" --tags Key="$TAG_KEY",Value="Subnet-$TAG_VALUE" --region "$REGION" '''
- ''' echo "Subnet tagged with $TAG_KEY=Subnet-$TAG_VALUE" '''
- ''' IGW_ID=$(aws ec2 create-internet-gateway --region "$REGION" --query 'InternetGateway.InternetGatewayId' --output text) '''
- ''' echo "Internet Gateway created successfully in region "$REGION" with ID: "$IGW_ID" " '''
- ''' aws ec2 attach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" --region "$REGION" '''
- ''' echo "Internet Gateway $IGW_ID successfully attached to VPC "$VPC_ID" in region "$REGION"." '''
- ''' ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --region "$REGION" --query 'RouteTable.RouteTableId' --output text) '''
- ''' echo "Route Table created with ID: "$ROUTE_TABLE_ID"" '''
- ''' aws ec2 create-route --route-table-id "$ROUTE_TABLE_ID" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW_ID" --region "$REGION" '''
- ''' echo "Route successfully added to Route Table "$ROUTE_TABLE_ID" " '''
- ''' aws ec2 associate-route-table --route-table-id "$ROUTE_TABLE_ID" --subnet-id "$SUBNET_ID" --region "$REGION" '''
- ''' echo "Subnet "$SUBNET_ID" successfully associated with Route Table "$ROUTE_TABLE_ID" " '''
- ''' SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name "$SECURITY_GROUP_NAME" --description "$SECURITY_GROUP_DESC" --vpc-id "$VPC_ID" --region "$REGION" --query 'GroupId' --output text) '''
- ''' echo "Security Group created successfully with ID: "$SECURITY_GROUP_ID" " '''
- ''' aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0 --region "$REGION" '''
- ''' aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 --region "$REGION" '''
- ''' aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 443 --cidr 0.0.0.0/0 --region "$REGION" '''

- ''' echo "VPC ID: "$VPC_ID" "
      echo "Subnet ID: "$SUBNET_ID" "
      echo "Internet Gateway ID: "$IGW_ID" "
      echo "Route Table ID: "$ROUTE_TABLE_ID" "
      echo "Security Group ID: "$SECURITY_GROUP_ID" " '''
  
### Create AWS Key Pair 

- ''' KEY_NAME="my-project-keypair"
      KEY_FILE="${KEY_NAME}.pem" '''
  
- ''' aws ec2 create-key-pair --key-name "$KEY_NAME" --query 'KeyMaterial' --output text > "$KEY_FILE" '''
- ''' echo "Key pair "$KEY_NAME" created successfully and saved as "$KEY_FILE" " '''
- ''' chmod 400 "$KEY_FILE" '''



the architecture is to create two ec2 machines which on one ec2 machine will be installed nginx as a webserver that recieves ingress from another ec2 machine that runs jenkins for ci/cd with docker installed, 
that way the ec2 instace will serve as jenkins master and te docker containers in it will be the workers. 
the two ec2 instances will communicate with each other, jenkins thru its workers will send missions to the nginx webserver 

- aws ec2 create-key-pair --key-name EC2KeyPair --query "KeyMaterial" --output text > EC2KeyPair.pem
- chmod 400 EC2KeyPair.pem
- aws ec2 describe-key-pairs
- !!!!! need to create a subnet, check instructions !!!!!
- !!!!! need to create a VPC, check instructions !!!!!!
- aws ec2 run-instances --image-id ami-087c17d1fe0178315 --count 1 --instance-type t2.micro --key-name EC2KeyPair  --security-group-ids sg-092c59c4855a0a12d --subnet-id subnet-068f7b1d93da3fc7e --associate-public-ip-address --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=Demo-EC2}]'
-  ssh -i "EC2KeyPair.pem" ubuntu@3.92.141.150 -v ## deppends on the used image, you can see the default user on the console ## to connect to EC2 need to use the public id (not private ip) ##
