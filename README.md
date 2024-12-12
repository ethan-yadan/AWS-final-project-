# AWS-final-project
AWS Final Project - Technion DevOps

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

![AWS Arch](course_HA_example.png)

## Steps 

- install and update standard python and debian linux
- install and update aws cli on your linux debian vm
- aws configure your account to your vm (aws access key ID, aws secret access key, aws region name and output format)
- us-east-1 ubuntu 24.04 LTS ami : ami-087c17d1fe0178315
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
!!!! pay attention, you have to run all the commands in alex's post in telegram, meanning to create an entire architecture to be able to connect to this machine from the world
what i did in class was to create an EC2 but without all of the configuration (vpc, subnet, cid ... etc) it's not possible to connect from the world to the EC2 !!!!


- aws ec2 create-key-pair --key-name EC2KeyPair --query "KeyMaterial" --output text > EC2KeyPair.pem
- chmod 400 EC2KeyPair.pem
- aws ec2 describe-key-pairs
- !!!!! need to create a subnet, check instructions !!!!!
- !!!!! need to create a VPC, check instructions !!!!!!
- aws ec2 run-instances --image-id ami-087c17d1fe0178315 --count 1 --instance-type t2.micro --key-name EC2KeyPair  --security-group-ids sg-092c59c4855a0a12d --subnet-id subnet-068f7b1d93da3fc7e --associate-public-ip-address --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=Demo-EC2}]'
-  ssh -i "EC2KeyPair.pem" ubuntu@3.92.141.150 -v ## deppends on the used image, you can see the default user on the console ## to connect to EC2 need to use the public id (not private ip) ##
