# A quest in the clouds

### Q. What is this quest ?
#####  It is a fun way to assess your cloud skills. It is also a good representative sample of the work we do at Rearc. Quest is a webapp made with node.js and golang.

### Q. Do i need to be an expert in node.js and golang ?
#####  No. The starting point of the quest app is `npm install && npm start`. That is all the node.js you need to know. And you wont even see golang.

### Q. So what skills should i have ?
#####  AWS. Cloud concepts. Docker (containerization). IAC (Infrastructure as code). HTTP/HTTPS. Linux/Unix.

### Q. What do i have to do ?
#####   1) Deploy the app in AWS and find the secret page. Use Linux 64-bit as your OS (Amazon Linux preferred)
#####   2) Deploy the app in a Docker container. Use `node:10` as the base image
#####   3) Inject an environment variable (SECRET_WORD) in the docker container. The value of SECRET_WORD should be the secret word discovered on the secret page
#####   4) Deploy a loadbalancer in front of the app
#####   5) Complete "Terraform"ing and/or "Cloudformation"ing the entire stack for "single click" deployment (Use the latest version of Terraform available at the time)
#####   6) Add TLS (https). Its OK to use locally generated certs.

### Q. How do i know i have solved these stages ?
#####  Each stage can be tested as follows (where <ip_or_host> is the location where the app is deployed) 
#####   1) AWS/Secret page - `http(s)://<ip_or_host>[:port]/`
#####   2) Docker - `http(s)://<ip_or_host>[:port]/docker`
#####   3) SECRET_WORD env variable - `http(s)://<ip_or_host>[:port]/secret_word`
#####   4) Loadbalancer - `http(s)://<ip_or_host>[:port]/loadbalanced`
#####   5) Terraform and/or Cloudformation - we will test your submitted templates in our AWS account
#####   6) TLS - `http(s)://<ip_or_host>[:port]/tls`

### Q. Do i have to do all these ?
#####  You can do as many as you like. We suspect though that once you start you wont be able to stop. Its addictive.

### Q. What do i have to submit ?
#####   1) Terraform and/or Cloudformation template(s) (if you complete stage 5)
#####   2) Dockerfile (if you complete stages 2 and 3)
#####   3) Screenshot of the secret page (if you complete stage 1)
#####   4) URL of your stack (if the endpoint is exposed)

### Q. What if i successfully complete all the challenges ?
#####  We have many more for you to solve as a member of the Rearc team !

### Q. What if i find a bug ?
#####  Awesome! Lets talk.

### Q. What if i fail ?
#####  Do. Or do not. There is no fail.

### Q. Can i share this quest with others ?
##### No.
