#!/bin/bash

############### Start of Secure Header ###############
# Created by: Eitan Yadan                            #
# Purpose: Launching Jenkins in EC2 Instance         #
# Version: 1.0.2                                     #
# Date: 17.12.2024                                   #
set -o errexit                                       #
set -o pipefail                                      #
set -o nounset                                       #
set -x                                               #
############### End of Secure Header #################

# 1. Update packages and install dependencies
echo "Updating package list and installing prerequisites..." 
sudo apt-get update -y 
sudo apt-get install -y ca-certificates curl

# 2. Adding Docker's GPG key
echo "Adding Docker's GPG Key..." 
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 3. Adding the Docker repository 
echo "Adding Docker repository to apt sources..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# 4. Install Docker  
echo "Installing Docker..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Pull Jenkins Docker Image 
echo "Pulling Jenkins Docker image..."
sudo docker pull jenkins/jenkins

# 6. Run Jenkins container 
echo "Starting Jenkins container..."
sudo docker run -itd -p 80:8080 --name jenkins_container jenkins/jenkins

# 7. Display container details 
echo "Listing Docker images..." 
sudo docker images
echo "Jenkins container is running. Access Jenkins at http://ec2publicIP:80"

# 8. Retrieve initial admin password
echo "Retrieving Jenkins initial admin password..."
sudo docker exec -it jenkins_container /bin/bash 
cat /var/jenkins_home/secrets/initialAdminPassword

echo "Copy the token above and paste it into the web browser to complete Jenkins setup."

