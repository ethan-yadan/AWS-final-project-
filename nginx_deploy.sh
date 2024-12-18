#!/bin/bash

############### Start of Secure Header ###############
# Created by: Eitan Yadan                            #
# Purpose: deploy nginx on ec2 instance              #
# Version: 1.0.1                                     #
# Date: 18.12.2024                                   #
set -o errexit                                       #
set -o pipefail                                      #
set -o nounset                                       #
set -x                                               #
############### End of Secure Header #################

# 1. Update packages and install dependencies
echo "Updating package list and installing prerequisites..." 
sudo apt update && sudo apt upgrade -y

# 2. Installing nginx 
echo "Installing nginx..."
sudo apt install nginx -y

# 3. Start and enable nginx
echo "Start and enable nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# 4. Check nginx Status
echo "Check nginx status..."
sudo systemctl status nginx