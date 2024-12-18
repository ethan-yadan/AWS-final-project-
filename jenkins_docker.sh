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


sudo apt update

sudo curl -fsSL https://get.docker.com -o install-docker.sh

sudo apt-get update
sudo apt-get install ca-certificates curl -y 
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
 
 # pull image
docker pull jenkins/jenkins

# view images and see thier IDs
docker images

#run
docker run -itd -p 8080:8080 --name jenkins_container <ImageID> # you get in earlier step

#Use the web browser to navigate to:

localhost:8080
# a token is needed. run:
docker exec -it jenkins_container /bin/bash

#in the container, run:
cat /var/jenkins_home/secrets/initialAdminPassword

#copy and paste the token into the web browser.
