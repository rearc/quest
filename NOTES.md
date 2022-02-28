# Notes

## Part 1+2

Manually Created an free instance on AWS to test the initial code.
Followed guide here to get Node running on blank instance: <https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-up-node-on-ec2-instance.html>
Also installed git
I understand that an instance can be used that includes nodeJS and git previously installed, but I like to start with a blank slate when initially testing.

### Commands Used

```bash
sudo yum update
sudo yum install git
sudo yum update curl -o- <https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh> | bash
. ~/.nvm/nvm.sh
nvm install node
git clone https://github.com/jonfinley/quest
cd quest/
node install
npm run start
```

### View Secrete Word

AWS browse to `http://34.207.87.89:3000`

Secret Word was viewed

## Part 3 - dockerization

This portion was borrowed from a small project I am rewriting from php to nodejs. complete redesign that has been postponed for about 2.5 years now. I
Dockerfile base was written and updated with the secret_word, seems to get stuck at the end of the build process after `# Rearc quest listening on port 3000!`
Adjusted dockerfile line 21
Github Container Registry Created with github actions
ECR Created with Terraform and AWS CLI

```bash
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 837525715721.dkr.ecr.us-east-2.amazonaws.com
docker build -t rearc-quest .
docker tag rearc-quest:latest 837525715721.dkr.ecr.us-east-2.amazonaws.com/rearc-quest:latest
docker push 837525715721.dkr.ecr.us-east-2.amazonaws.com/rearc-quest:latest
```

## Part 4 - Terraform

Built the Terraform main.tf

## Part 5 - SSL

I built the terraform portion to request the cert from AWS and edit my CF DNS. One of my learning sources over the past few weeks was <https://medium.com/avmconsulting-blog/how-to-deploy-a-dockerised-node-js-application-on-aws-ecs-with-terraform-3e6bceb48785>

So I utilized the notes I had kept and rebuilt it for this application. For the remainder, I used:

- <https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs>
- <https://github.com/terraform-aws-modules/terraform-aws-acm/tree/v3.3.0>

There are also some missing files.
