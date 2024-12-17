 # pull image
docker pull jenkins/jenkins

# view images and see thier IDs
docker images

#run
docker run -itd -p 8080:8080 --name jenkins_container <ImageID>

#Use the web browser to navigate to:

localhost:8080
# a token is needed. run:
docker exec -it jenkins_container /bin/bash

#in the container, run:
cat /var/jenkins_home/secrets/initialAdminPassword

#copy and paste the token into the web browser.
