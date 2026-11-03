# A quest in the clouds

### Q. What is this quest?
It is a fun way to assess your cloud skills. It is also a good representative sample of the work we do at Rearc. We've built the Quest webapp with Node.js and golang. Your job, should you wish to accept it, is to complete a series of tasks to make it run in the cloud.

### Q. So what skills should I have?
- Public cloud: AWS, GCP, Azure.
  - More than one cloud is a "good to have" but one is a "must have".
- General cloud concepts, especially networking.
- Containerization, such as: Docker, containerd, Kubernetes.
- IaC (Infrastructure as code). At least some Terraform preferred.
- Linux (or other POSIX OS).
- VCS (Version Control System). Git is highly preferred.
- TLS is a plus.

### Q. What do I have to do?
You may do all or some of the following tasks. Please read over the complete list before starting.

1. If you know how to use git, start a git repository (local-only is acceptable) using the webapp files included in this repo as a starting point. Commit all of your work to it.
2. Use Infrastructure as Code (IaC) to deploy the code as specified below.
   - Terraform is ideal, but use whatever you know, e.g. CloudFormation, CDK, Deployment Manager, etc.
3. Deploy the app in a container in any public cloud using the services you think best solve this problem.
   - Use `node` as the base image. Node.js 18 or later is required (any active LTS release works).
   - Install the dependencies with `npm install` or `npm ci`.
4. Navigate to the index page to obtain the SECRET_WORD.
   - The secret word changes periodically. If the secret word check says your word is no longer current, set `SECRET_WORD` to the word the index page shows now.
5. Inject an environment variable (`SECRET_WORD`) in the container using the value on the index page.
6. Deploy a load balancer in front of the app.
7. Add TLS (https). You may use locally-generated certs.

### Q. How do I know I have solved these stages?
Each stage can be tested as follows (where `<ip_or_host>` is the location where the app is deployed):

1. Public cloud & index page (contains the secret word) - `http(s)://<ip_or_host>[:port]/`
2. Docker check - `http(s)://<ip_or_host>[:port]/docker`
3. Secret Word check - `http(s)://<ip_or_host>[:port]/secret_word`
4. Load Balancer check - `http(s)://<ip_or_host>[:port]/loadbalanced`
5. TLS check - `http(s)://<ip_or_host>[:port]/tls`

A few notes on the checks:
- **Public cloud (1)**: AWS, GCP, and Azure are recognized. If you use another cloud, or your platform isn't detected, let us know what you are using and we can provide you with a secret word.
- **Docker check (2)**: despite the name, this check recognizes many other container runtimes and platforms.
- **Secret Word check (3)**: checks that `SECRET_WORD` holds a recent secret word.
- **TLS check (5)**: checks for upstream TLS termination.

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
   - **This may carry as much weight as the code itself.**

Your work assets should include:

- IaC files, if you completed that task.
- One or more Dockerfiles, if you completed that task.
- A sensible README or other file(s) that contain instructions, notes, or other written documentation to help us review and assess your submission.
  - Please include the quest version (from `package.json`, currently `1.3.0`) that you used for your submission.
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

### Q. Is it safe to run the quest binaries in my cloud account?
The Go binaries in `bin/` are closed source because they check your solution. They need no credentials, cloud permissions, or outbound internet access, and they write nothing outside the container. Run them the way you would run any untrusted third-party workload:

- Use a sandbox or free-tier account (or project or subscription) with nothing else in it, and set a budget alert.
- Give the container no IAM role, service account, or managed identity, and no access to secrets (`SECRET_WORD` can be in the environment, it is not security sensitive).
- Run it as a non-root user with a read-only root filesystem and all Linux capabilities dropped.
- Expose only the container's HTTP port 3000. You can block all network egress.
- You can stop the service or even tear everything down once you have your screenshot.

None of this affects the checks, and a locked-down deployment is a good thing to show in your submission.

### Q. Can I use AI to assist me?
You may use AI as a reference tool but there will be a strong expectation to exhibit the same expertise and understanding from your submission in your interview. In addition we encourage you to be open about any usage! Please document what you used, what your prompts were, how it helped, what it got wrong, etc.
