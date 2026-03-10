# Solution

Below is an overview of my architectural decisions and the reasoning behind each.

## Implementation Choices

1. **Version Control** — This repository is public and available for review.

2. **Infrastructure as Code: Terraform** — Terraform is the industry standard for cloud IaC and the tool I have the most production depth with. It provides a clear, auditable, declarative state model well-suited for client-facing deliverables.

3. **Cloud Provider: AWS (primary) / IBM Cloud (bonus)**
   - The `dev-ibm` branch contains a parallel implementation in IBM Cloud, included as an exploration of multi-cloud portability.
   - **Compute: ECS Fargate** — Fargate was selected because it abstracts away EC2 instance management entirely. From a security and compliance standpoint, this is a meaningful architectural choice: by offloading host-level responsibility to AWS under the shared responsibility model, we eliminate the EC2 patching and host-hardening surface from vulnerability management and audit scope. This simplifies compliance posture significantly while maintaining full application-layer control. Container and application-level vulnerabilities remain in scope and are addressed separately (see improvements below).

4. **Proof of completion** — See `proof.png`.

5. **Secret Word Injection via Terraform Task Definition**
   - The `SECRET_WORD` environment variable is injected at the ECS task definition level via Terraform rather than hardcoded in the Dockerfile. This decouples configuration from the container image, enabling environment-specific overrides without rebuilding images.
   - Because this value is intended to be publicly displayed, a secrets manager (e.g., AWS Secrets Manager, Parameter Store) was not used. In a production system handling sensitive values, that would be the appropriate pattern.

6. **Load Balancer: Application Load Balancer (ALB)**
   - An ALB is the appropriate choice for this workload. It integrates natively with ECS/Fargate for target registration and health checking, and provides first-class integration with AWS Certificate Manager (ACM) for TLS termination.

7. **TLS: Self-Signed Certificate via Terraform + ACM**
   - A self-signed certificate is generated and uploaded to ACM using Terraform, keeping the TLS configuration fully automated and version-controlled.
   - Certificate validity is set to **47 days** to align with the [CA/Browser Forum's anticipated 2029 maximum validity requirements](https://cabforum.org/), demonstrating forward-looking compliance awareness.

---

## Given More Time, I Would Improve...

The following items represent known gaps I would address to bring this to a production-ready, client-deliverable standard:

1. **Terraform Module Abstraction**
   - The current implementation uses raw Terraform resources intentionally. ECS/Fargate is not a resource set I build daily in my security engineering role, and working at the resource level was a deliberate choice to deepen familiarity and build the muscle memory needed to own this infrastructure confidently.
   - In a client engagement, this would be refactored into a reusable module with sensible defaults, input validation, and published documentation.

2. **CI/CD Pipeline**
   A full pipeline would include:
   - **Static analysis:** `tflint`, trailing whitespace, Terraform formatting checks
   - **Security scanning:** SCA (dependency vulnerabilities), SAST, IaC scanning (e.g., Checkov, tfsec), Dockerfile scanning (e.g., Trivy, Grype)
   - **Container build pipeline:** Automated image builds on commit with digest pinning
   - **Dynamic testing:** OWASP ZAP scan against the deployed URL in an ephemeral test environment
   - **End-to-end verification:** Automated validation of all `/check` endpoints using Terraform outputs

3. **Container Image Hardening**
   - The `node:25` base image is large and carries unnecessary packages, each representing additional CVE surface area.
   - The recommended path is migrating to a distroless or [Chainguard](https://www.chainguard.dev/) base image, which routinely achieves near-zero known CVEs at the OS layer while maintaining compatibility with Node.js workloads.

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
