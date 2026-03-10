# Solution
Here is an explanation of some of my choices

1. This is a public git repo feel free to look around and share with your friends!
2. I have the most experience with terraform and it is more or less the industry standard.
3. I did this in AWS but also for funsies gave it a shot in IBM Cloud
   - see dev-ibm branch for that silliness
   - I used ECS fargate because fargate allows us not to worry about an EC2 instance. In the real world it also offloads the ec2 related compliance requirements over to AWS in the shared responsibility model. This is important to me as a security engineer who has had to manage large scale audits because then i get to tell auditors that patching the host is Amazon's deal. This greatly reduces the vulnerability management burden from a compliance perspective. You of course also need to pay attention to container and application level vulns still.
4. See proof.png
5. I injected the env variable using tf in the task definition.
   - In a real world scenario this would make it more flexible than in the dockerfile
   - The word is meant to be displayed publically so i didnt use a secret store to inject it.
6. An ALB is appropriate for this, it integrates natively with ECS and fargate.
   - Also integrates with ACM well for the TLS requirement
7. We generate a self signed cert with terraform and upload to ACM
   - Cert validity is 47 days to meet the 2029 tls cert validity goal.

### Given more time, I would improve...
Some things i would improve to "productionize" this. In no particular order

1. Create and use a terraform module instead of using raw resources
   - This is of course a best practice and allows you to reuse the module code with sensible defaults and etc.
   - The reason i chose to use raw resources for the quest was because as a security engineer i have less practice and familiarity with building ECS applications. It seemed like a good opportunity to gain practice, familiarity, and muscle memory with a set of resources I dont generally get to build in my day job.
2. Setup a CICD pipeline with all the standard jobs
   - Standard linters (tflint, trailing white spaces, etc)
   - Docker container build pipeline
   - Static security tests: SCA, SAST, IAC scan, dockerfile scan
   - Dynamic testing: Using the terraform outputs run OWASP zap against the index URL in a test environment.
   - E2E testing: Using the check_url outputs check for expected results
3. Optimize Docker Image
   - the standard node:25 base image is large and contains plenty of things we don't need.
   - These things we dont need take up space and all create opportunities for more CVEs
   - Chainguard images are good baselines for near 0 CVE base images.

# A quest in the clouds

### Q. What is this quest?

It is a fun way to assess your cloud skills. It is also a good representative sample of the work we do at Rearc. We've built the Quest webapp with node.js and golang. Your job, should you wish to accept it, is to complete a series of tasks to make it run in the cloud. 

### Q. So what skills should I have?
- Public cloud: AWS, GCP, Azure.
  - More than one cloud is a "good to have" but one is a "must have".
- General cloud concepts, especially networking.
- Containerization, such as: Docker, containerd, kubernetes
- IaC (Infrastructure as code). At least some Terraform preferred.
- Linux (or other POSIX OS).
- VCS (Version Control System). Git is highly preferred. 
- TLS is a plus.

### Q. What do I have to do?
You may do all or some of the following tasks. Please read over the complete list before starting.

1. If you know how to use git, start a git repository (local-only is acceptable) using the webapp files included in this repo as a starting point. Commit all of your work to it.
2. Use Infrastructure as Code (IaC) to the deploy the code as specified below.
   - Terraform is ideal, but use whatever you know, e.g. CloudFormation, CDK, Deployment Manager, etc.
3. Deploy the app in a container in any public cloud using the services you think best solve this problem.
   - Use `node` as the base image. Version `node:10` or later should work.
4. Navigate to the index page to obtain the SECRET_WORD.
5. Inject an environment variable (`SECRET_WORD`) in the Docker container using the value on the index page.
6. Deploy a load balancer in front of the app.
7. Add TLS (https). You may use locally-generated certs.

### Q. How do I know I have solved these stages?
Each stage can be tested as follows (where `<ip_or_host>` is the location where the app is deployed):

1. Public cloud & index page (contains the secret word) - `http(s)://<ip_or_host>[:port]/`
2. Docker check - `http(s)://<ip_or_host>[:port]/docker`
3. Secret Word check - `http(s)://<ip_or_host>[:port]/secret_word`
4. Load Balancer check  - `http(s)://<ip_or_host>[:port]/loadbalanced`
5. TLS check - `http(s)://<ip_or_host>[:port]/tls`

### Q. Do I have to do all these?
You may do whichever, and however many, of the tasks above as you'd like. We suspect that once you start, you won't be able to stop. It's addictive. Extra credit if you are able to submit working entries for more than one cloud provider.

### Q. What do I have to submit?
1. Your work assets, as one or both of the following:
   - A link to a hosted git repository.
   - A compressed file containing your project directory (zip, tgz, etc). Include the `.git` sub-directory if you used git.
2. Proof of completion, as one or both of the following:
   - Link(s) to hosted public cloud deployment(s).
   - One or more screenshots showing, at least, the index page of the final deployment in one or more public cloud(s) you have chosen.
3. An answer to the prompt: "Given more time, I would improve..."
   - Discuss any shortcomings/immaturities in your solution and the reasons behind them (lack of time is a perfectly fine reason!)
   - **This may carry as much weight as the code itself**

Your work assets should include:

- IaC files, if you completed that task.
- One or more Dockerfiles, if you completed that task.
- A sensible README or other file(s) that contain instructions, notes, or other written documentation to help us review and assess your submission.
  - **Note** - the more this looks like a finished solution to deliver to a customer, the better.

### Q. How long do I need to host my submission on public cloud(s)?
You don't have to at all if you don't want to. You can run it in public cloud(s), grab a screenshot, then tear it all down to avoid costs.

If you _want_ to host it longer for us to view it, we recommend taking a screenshot anyway and sending that along with the link. Then you can tear down the quest whenever you want and we'll still have the screenshot. We recommend waiting no longer than one week after sending us the link before tearing it down.

### Q. What if I successfully complete all the challenges?
We have many more for you to solve as a member of the Rearc team!

### Q. What if I find a bug or part of my solution isn't detected?
Awesome! Tell us you found a bug or that the quest can't detect a task you've solved when you submit your quest and we'll talk more!

### Q. What if I fail?
There is no fail. Complete whatever you can and then submit your work. Doing _everything_ in the quest is not a guarantee that you will "pass" the quest, just like not doing something is not a guarantee you will "fail" the quest.

### Q. Can I share this quest with others?
No. After interviewing, please change any solutions shared publicly to be private.

### Q. Do I have to spend money out of my own pocket to complete the quest?
No. There are many possible solutions to this quest that would be zero cost to you when using [AWS](https://aws.amazon.com/free), [GCP](https://cloud.google.com/free), or [Azure](https://azure.microsoft.com/en-us/pricing/free-services).

### Q. Can I use AI to assist me?
You may use AI as a reference tool but there will be a strong expectation to exhibit the same expertise and understanding from your submission in your interview. In addition we encourage you to be open about any usage! Please document what you used, what your prompts were, how it helped, what it got wrong, etc.
