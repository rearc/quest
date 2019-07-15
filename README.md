# quest
## A quest in the clouds

#### Q. What is this quest ?
##### A. It is a fun way to assess your cloud skills.

#### Q. What do i have to do ?
A. 1) Deploy the app in AWS and find the secret page
   2) Deploy the app in AWS in a Docker container
   3) Deploy a loadbalancer in front of the app
   4) Complete "Terraform"ing and/or "Cloudformation"ing the entire stack for single click deployment
   5) Add TLS (https)

#### Q. How do i know i have solved these stages ?
A. Each stage can be tested as follows (where <ip_or_host> is the location where the app is deployed) 
   1) AWS/Secret page - http(s)://<ip_or_host>[:port]/
   2) Docker - http(s)://<ip_or_host>[:port]/docker
   3) Loadbalancer - http(s)://<ip_or_host>[:port]/loadbalanced
   4) Terraform and/or Cloudformation - we will test your submitted templates in our account
   5) TLS - http(s)://<ip_or_host>[:port]/tls

#### Q. Do i have to do all these ?
A. You can do as many as you like. We suspect though that once you start you wont be able to stop. Its addictive.

#### Q. What do i have to submit ?
A. 1) Terraform and/or Cloudformation template(s) (if you complete step 4)
   2) Dockerfile (if you complete step 2)
   3) Screenshot of the secret page (if you complete step 1)
   4) URL of your stack (if the endpoint is exposed)

#### Q. What if i successfully complete all the challenges ?
A. We have many more for you to solve as a member of the Rearc team !
