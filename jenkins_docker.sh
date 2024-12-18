#!/bin/bash

############### Start of Secure Header ###############
# Created by: Eitan Yadan                            #
# Purpose: Launching Jenkins in EC2 Instance         #
# Version: 1.0.1                                     #
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

# Adding the repository to Apt sources: 
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install the Docker image: 
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Pull Jenkins image: 
sudo docker pull jenkins/jenkins

# view images and see thier IDs
sudo docker images

#run
sudo docker run -itd -p 8080:8080 --name jenkins_container <ImageID> # you get in earlier step

#Use the web browser to navigate to:

localhost:8080
# a token is needed. run:
docker exec -it jenkins_container /bin/bash

#in the container, run:
cat /var/jenkins_home/secrets/initialAdminPassword

#copy and paste the token into the web browser.
