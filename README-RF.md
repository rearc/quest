# Attempt at Quest Challenge by Ryan Findley

This will document the steps I took in attempting to complete the Quest Challenge presented to me by Rearc. The code will be pushed to a GitHub repository [https://github.com/r-findley/quest-rearc] for sharing with the Rearc team.

## Steps Taken To Complete

1. My thought process began with simply creating a separate git repository and copying the Quest code into this to give me my own implementation to work with. This was committed as my initial commit with this first step written for the README.

2. The next path I followed was to create the Dockerfile to containerize the app. I've been working with understanding more about Docker in my own development and felt the most comfortable with this process. I also created a .dockerignore file as part of this step as this is also part of my own development practice. I built the image to review and verify that it was working as expected.

3. After creation of the Dockerfile and successful building of the image I was able to view localhost:3000/docker. This displayed a blank page with no information - this was better than the result I got on the localhost:3000 page of /bin/sh: 1: bin/001: not found :). This step felt like a good stopping point for my first attempt. I therefore pushed this code back to my repo and began searching for information on deploying to AWS.

4. To begin exploring deployment via AWS I did some research online. I have not done this before so I wanted to read up on how this works before attempting. Being my first experience I started with downloading the AWS CLI (version 2 based on the documentation I read on AWS).

5. After getting the AWS CLI installed I created an access key from AWS and connected to my CLI. I then pushed the docker image already created to an Amazon ECR. I created a cluster with the image included and ran this, also getting a blank page.

6. I started a new path in my thinking. I went through some tutorials online for how to launch an EC2 instance and get the code into this. I was able to launch the Amazon Linux 2 instance, install node/git and clone the repo into this instance. From there I was not successful in getting the app to run.

7. I spent some time then in the Dockerfile again. I used the exec command to enter the container and see if any logs presented. I was unable to glean anything from this but it gave me the idea to attempt to install docker inside the ec2 and build the image there.

8. Having attempted to build the  image in the EC2 I instead pushed my current image to docker hub and pulled this down from within the EC2 instance. I ran this inside the container to successfully build the container.

9. I then stepped back to just try to run something in the instance. I made a remote connection to VS Code to begin coding a simple sample app in express to try to run. This successfully ran and showed me the code that I wrote. I therefore proved I can in fact get an EC2 instance running and have code show up in this. I set this up on port 4500 and successfully allowed this to be seen by my security groups.

10. I also opened up the quest code in a remote VS Code inside my EC2 instance and changed the port to 4000 on the express file, adding this as an allowed port to my security group as well. I still ran into the same issues of seeing the permission denied flag.

11. With the above not working I reviewed the use of AWS Beanstalk. I was able to create an application and get this up and running with an NGINX error due to a bad gateway. Some research uncovered that Beanstalk publishes on port 8081 even though the file in the code base suggests a port of 3000. I updated the file to show const port = process.env.PORT || 3000 and added an environment variable inside the Beanstalk instance for port 8081. This allowed me to access the site but I again got the permission denied warning.

12. After a break I tried my EC2 instance again, this time cloning straight from the GitHub repo shared to me by Rearc. This was successful! I therefore forked the Rearc repo and ran this successfully as well. THat is where I will be submitting this code.

13. I then created my Dockerfile and got the project running in a Docker container as well on port 3500. I also added the secret word variable into the container at this point.
