# Notes

What a fun project! The following are my notes.

## Part 1+2

Manually Created an free instance on AWS to test the initial code.
Followed guide here to get Node running on blank instance: <https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-up-node-on-ec2-instance.html>
Also installed git, I understand that an instance can be used that includes nodeJS and git previously installed, but I like to start with a blank slate when initially testing.

### Commands Used

```bash
sudo yum update
sudo yum install git
sudo yum update curl -o- <https://raw.githubusercontent.com/nvm-sh/nbvm/v0.34.0/install.sh> | bash
. ~/.nvm/nvm.sh
nvm install node
git clone https://github.com/jonfinley/quest
cd quest/
node install
npm run start
```

### View Secret Word

Browse to `http://public_ip:3000`

## Part 3 - dockerization

This portion was borrowed from a small project I am rewriting from php to nodejs. complete redesign that has been postponed for about 2.5 years now. I
Dockerfile base was written and updated with the secret_word, seems to get stuck at the end of the build process after `# Rearc quest listening on port 3000!`
Adjusted dockerfile line 21
Github Container Registry Created with github actions
ECR Created with Terraform and AWS CLI. One of my learning sources conveniently for terraform was <https://medium.com/avmconsulting-blog/how-to-deploy-a-dockerised-node-js-application-on-aws-ecs-with-terraform-3e6bceb48785>

```bash
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 837525715721.dkr.ecr.us-east-2.amazonaws.com
docker build -t rearc-quest .
docker tag rearc-quest:latest 837525715721.dkr.ecr.us-east-2.amazonaws.com/rearc-quest:latest
docker push 837525715721.dkr.ecr.us-east-2.amazonaws.com/rearc-quest:latest
```

## Part 4 - Terraform

### main.TF

This includes all of my providers (AWS and Cloudflare) and information to use Terraform Cloud.

### aws.tf

This includes the AWS configs used.

### cloudflare.tf

This includes the Cloudflare configs used.

### extra notes

- I used terraform.tfvars locally before moving to Terraform Cloud. All Secrets (except the secret word) are stored in either the GitHub Repo's Secrets or Terraform Cloud Project Secrets.

- I host my DNS using Cloudflare so this is the reason I did not use Route53.

## Part 5 - SSL

I built the terraform portion to request the cert from AWS and edit my CF DNS.
Docs used:

- <https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs>
- <https://github.com/terraform-aws-modules/terraform-aws-acm/tree/v3.3.0>

## Notes I found during development

- Initially i tried to run the docker locally on my machine. I typically do most of my testing local before pushing it to the cloud in order to nuke any mistakes. This was unable to be done at first due to a wrong configuration in the file. Once I corrected that I was able to get it running and saw the message that says it is not running, basically, in the cloud.

- Given more time, i would have liked to get Azure and GCP working, but since I am still learning Azure and am not in GCP regularly, I felt it important to showcase my understanding of the AWS environment.

- Terraform is still relatively _new_ to me and I had some trials when moving the deployment to a full on GitHub Actions. One of the major trials I had was: "503 Service unavailable." going through the initial overview of the code and configs told me everything looked right, even down to the variables that Terraform "cleaned up" (one was messed up after that). But then I quickly realized A. the containers are not getting created, B. they arent getting created because !! the code had not been pushed and the container image was not created in ECR.

- Quickly pushed that code and noticed that it was working at that time. Moving forward, I would consider moving this action separately into a github action on it's own instead of tying it into the main.tf

- This was also a flaw in my _mis_-understanding of Terraform and was a pretty good learning lesson.

- One other thing that I missed once moving the Terraform deployment to GitHub Actions was a dependancy I did not think about as I was building the terraform config. In order for the 80 to 443 redirect, especially since I was using an Amazon Cert instead of a CloudFlare certificate I needed to wait to create the 443 LB until after the Certificate was complete.

- I would also move the secret word variable to "outside" the dockerfile.

- One of my last things I would do is add infracost <https://www.infracost.io/docs/> to the GH Pipeline. I think it is important to know (especially when using AWS, GCP, Azure) how much it costs to use their services. As we all know. Cloud Solutions can get pricy and I believe it important that A. we have a clear understanding of cost, and B. we can easily pass on that information to the customer. I did run it locally on my machine:

Project: jonfinley/quest/. (rq)

 Name                                              Monthly Qty  Unit              Monthly Cost

 aws_alb.rearc_quest_application_load_balancer
 ├─ Application load balancer                              730  hours                   $16.43
 └─ Load balancer capacity units                Monthly cost depends on usage: $5.84 per LCU

 aws_ecr_repository.rearc-quest
 └─ Storage                                     Monthly cost depends on usage: $0.10 per GB

 aws_ecs_service.rearc_quest
 ├─ Per GB per hour                                          2  GB                       $6.49
 └─ Per vCPU per hour                                        1  CPU                     $29.55

 OVERALL TOTAL                                                                          $52.47
──────────────────────────────────
18 cloud resources were detected, rerun with --show-skipped to see details:
∙ 3 were estimated, 2 include usage-based costs, see <https://infracost.io/usage-file>
∙ 15 were free

Add cost estimates to your pull requests: <https://infracost.io/cicd>

1. I have submitted this repo as the work assets.
2. I submitted the URL via email to the party handling my application.
3. NOTES.md (this file ^_^ ) contains my notes and answers.

- Terraform was used as IAC
- Single Dockerfile has been included in root
