# Rearc.io Quest Repository

## Structure
- Dockerfile - The container image blueprint where the application will be sotred
- cdk directory - Typescript installation of CDK framework that houses deployment code
  - This will deploy a ECS cluster, while creating a ECR repository to upload an image to, in a configuration that relies on spot instances when available, but will fail over to on-demand when needed.

## Implementation mindset and reasoning
- I decided to use CDK as Amazon Products are what I am most familiar with. I have a background in Cloudformation and CDK so I figured it would be best to use CDK to get things done swiftly.
- I decided to deploy the cluster in to ECS with the help of ECR, this is a great real world scenario and shows my capabilities and understanding.
  - ECS is a cost-effective solution compared to using a solution like EKS. 
    - EKS would cost a minimum of $70/month just to run the etcd control plane.
- I've made a makefile to assist with my debugging of the application in the container.
- There is a demonstration in the CDK code of multiple Capacity Providers and weighting, this demo makes use of Spot instances to save costs when available.
## Security issues
- The code provided with this quest makes use of exec which can be seen as a valid security issue. Executing unknown binaries from an unknown source without knowing their desired behavior could fit in the criteria of PUP (Potentially Unwanted Program), or even be malicious
  - In a production scenario, we would never use such a thing, even in a container
  - While the application is in a container, the application in question could utilize a zero-day exploit and escape the containerization engine, potentially harming other infrastructure in the same environment.

## Other information and things we could have done
- Estimated time to implement this repository is about 5 hours. CDK is still a fairly new framework and is lacking some capability compared to if I wrote this out in Cloudformation, but would have probably taken me longer on the discovery process.
  - Working with objects is easy, working with YAML and cross-referencing can be easy to get lost in for the scale of the tasks that we're working on in this scenario.
- We could have made end ot end tests to test the results of the deployment for us.
- We could have made a CI/CD process to automatically deploy the CDK stack and run the tests for us.
- I chose not to do these things out of time constraints.
- The quest was completed on the aarch64 architecture, you will find x86_64 specific hardcodings to ensure that we are using the proper platform.