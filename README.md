# A quest in the clouds

### Q. What is this quest?

It is a fun way to assess your cloud skills. It is also a good representative sample of the work we do at Rearc.

You will be given an application written in node.js and Golang, but no knowledge of these two languages is required. Then you will show that you understand how to deploy this application to the cloud.

### Q. What do I have to do?

You may do all or some of the following tasks. Please read over the complete list before starting.

**Note**: If you know how to use git, it is recommended to start a git repository (even if you don't host it anywhere), and commit your progress as you would normally on a work project.

To run the app, simply execute `npm run` (after installing dependencies).

1. Run the app and navigate to the index page. This is just to ensure you can get the app running as expected.
2. Deploy the app in a container. For Docker, use `node:10` as the base image.
3. Inject an environment variable (`SECRET_WORD`) in the container. The value of `SECRET_WORD` is found on the index page.
4. Deploy the application to the cloud. Use Linux 64-bit as your OS (for AWS, Amazon Linux is preferred).
5. Deploy a load balancer in front of the app.
6. Add TLS (https). You may use self-signed certs.
7. Use Infrastructure as Code (IaC) to "codify" your deployment. Terraform is ideal, but use whatever you know, e.g. CloudFormation, CDK, Deployment Manager, etc.

### Q. How do I know I have solved these stages?

Each "check" can be tested by visiting the following endpoints:

| Check Name | Endpoint Path |
| ---------- | ------------- |
| Index | `/` |
| Container | `/docker` |
| Secret Word | `/secret_word` |
| Load Balancer | `/loadbalanced` |
| TLS | `/tls` |

### Q. Do I have to do all these?

No. If you feel that time may be an issue, prioritize the above list of tasks and go as far as you can before you need to stop. You don't fail just because you didn't finish every single item in the list.

### Q. What do I have to submit?

1. Your work assets, as one or both of the following:
  - A link to a hosted git repository.
  - A ZIP file containing your project directory. Include the `.git` sub-directory if you used git.
2. Proof of completion, as one or both of the following:
  - A link to a hosted AWS deployment.
  - One or more screenshots showing, at least, the index page of the final deployment.

Your work assets should include:

- IaC files, if you completed that task.
- One or more container specs (e.g. Dockerfile), if you completed that task.
- A sensible README or other file(s) that contain instructions, notes, or other written documentation to help us review and assess your submission.

### Q. How long do I need to host my submission on AWS?

You don't have to at all if you don't want to. You can run it in AWS, grab a screenshot, then tear it all down to avoid costs.

If you _want_ to host it longer for us to view it, we recommend taking a screenshot anyway and sending that along with the link. Then you can tear down the quest whenever you want and we'll still have the screenshot. We recommend waiting no longer than one week after sending us the link before tearing it down.

### Q. What if I find a bug?

Awesome! Tell us you found a bug in your submission to us, ideally in an email, and we'll talk more!

### Q. Can I share this quest with others?

No.
