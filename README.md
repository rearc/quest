# A quest in the clouds

I have shortened the README to only contain the request and fulfillment criteria.

I will be deploying using the `rearc/quest` repository, not this one, since this one has the vulnerability patched (so my tests would pass). There will probably be a short writeup on that included with the deliverables.

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
