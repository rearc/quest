import {RemovalPolicy, Stack, StackProps} from 'aws-cdk-lib';
import {Construct} from 'constructs';
import * as ecr from 'aws-cdk-lib/aws-ecr';
import {DockerImageAsset} from "aws-cdk-lib/aws-ecr-assets";
import * as path from "path";
import * as ecrDeploy from 'cdk-ecr-deployment';
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as ecs from "aws-cdk-lib/aws-ecs";
import * as ecs_patterns from "aws-cdk-lib/aws-ecs-patterns";
import * as route53 from "aws-cdk-lib/aws-route53";
import {ApplicationProtocol} from "aws-cdk-lib/aws-elasticloadbalancingv2";
import * as crypto from "crypto";

export class CdkStack extends Stack {
    constructor(scope: Construct, id: string, props?: StackProps) {
        super(scope, id, props);

        /**
         * Helper method to generate the image tag.
         */
        const generateImageTag = function () {
            return process.env.GITHUB_SHA ?? crypto.randomBytes(20).toString('hex');
        }

        // We're going to containerize this application, so the first thing we're going to need is a repository to add it.
        const repository = new ecr.Repository(this, 'ApplicationRepository', {
            repositoryName: 'quest',
            imageScanOnPush: true,
            removalPolicy: RemovalPolicy.DESTROY
        });

        // Build our docker solution
        const image_ = new DockerImageAsset(this, 'ApplicationDockerImage', {
            directory: path.join(__dirname, '../../'),
            target: "prod",
        });

        // Deploy our docker solution to ECR.
        // Note: using tag latest is an anti-pattern, we're going to default to it if we are executing this locally
        // for debugging reasons, however, we will default to the git commit as the proper tag.
        const imageTag = generateImageTag();
        const ecrDeployment = new ecrDeploy.ECRDeployment(this, 'DeployApplicationDockerImage', {
            src: new ecrDeploy.DockerImageName(image_.imageUri),
            dest: new ecrDeploy.DockerImageName(`${repository.repositoryUri}:${imageTag}`),
        });

        // When that's done deploying, get our container image instance
        const ecrImage = ecs.ContainerImage.fromEcrRepository(
            repository,
            imageTag
        );

        /**
         * At this point now that we have our pre-requisites in place, we can go ahead and create our ECR instance.
         * This will consist of a cluster, a task definition, capacity providers, and the container definition.
         */

        // Create our cluster, we'll use insight to get a better idea for debugging.
        const cluster = new ecs.Cluster(this, 'ApplicationCluster', {
            containerInsights: true,
            enableFargateCapacityProviders: true,
        });

        // Add Capacity. We'll use spot when available, but use on-demand when spot isn't available.
        const spotCapacity = cluster.addCapacity('ClusterSpotCapacity', {
            instanceType: new ec2.InstanceType("t3.small"),
            desiredCapacity: 1,
            maxCapacity: 1,
            minCapacity: 1,
            spotPrice: '0.1',
            spotInstanceDraining: true,
        });
        const onDemandCapacity = cluster.addCapacity('ClusterDemandCapacity', {
            instanceType: new ec2.InstanceType("t3.small"),
            desiredCapacity: 0,
            maxCapacity: 1,
            minCapacity: 0,
        });

        // Add strategies for cost efficiency. Give spot a heavier weight to prefer it.
        const spotCapacityProviderStrategy: ecs.CapacityProviderStrategy = {
            capacityProvider: spotCapacity.autoScalingGroupName,
            weight: 2,
        };
        const onDemandCapacityProviderStrategy: ecs.CapacityProviderStrategy = {
            capacityProvider: onDemandCapacity.autoScalingGroupName,
            weight: 1,
        };

        // Create the webserver task.
        const applicationTask = new ecs.Ec2TaskDefinition(this, 'ApplicationTask', {});

        // Create a container definition for the task.
        const applicationContainer = applicationTask.addContainer("ApplicationContainer", {
            image: ecrImage,
            memoryLimitMiB: 512,
            cpu: 256,
            logging: ecs.LogDrivers.awsLogs({
                streamPrefix: 'webserver'
            }),
            environment: {
                /**
                 * REARC SECRET WORD
                 * https://www.rearc.io/quest001001222/
                 *
                 * In a production scenario, we wouldn't hardcode secrets!
                 * We could use SSM/Parameter Store/Secrets manager!
                 */
                SECRET_WORD: "TwelveFactor"
            }
        });

        // Map the port to the container.
        applicationContainer.addPortMappings({
            containerPort: 3000,
        });

        // The service that we're about to create requires HTTPS, CDK will let out the following error:
        // FIXME: throw new Error('A domain name and zone is required when using the HTTPS protocol');
        // We're going to get a real domain's hosted zone and provide it to the service.

        // NOTE TO REVIEWER: THIS IS A REAL DOMAIN.
        const domainName = "ely-learning-aws-domain.click";
        const domainHostedZone = route53.HostedZone.fromLookup(this, 'HostedZone', {
            domainName: domainName,
        });

        // Create the service, and by extent, the load balancer.
        // The load balancer will use the above hosted zone to create a record.
        const applicationService = new ecs_patterns.ApplicationLoadBalancedEc2Service(this, "ApplicationService", {
            cluster: cluster,
            taskDefinition: applicationTask,
            desiredCount: 1,
            protocol: ApplicationProtocol.HTTPS,
            redirectHTTP: true,
            domainName: `quest.${domainName}`,
            domainZone: domainHostedZone,
        });

        // Setting scalability boundaries. Extra credit.
        const webserverScalableTarget = applicationService.service.autoScaleTaskCount({
            minCapacity: 1,
            maxCapacity: 10,
        });
        webserverScalableTarget.scaleOnCpuUtilization('WebServerCpuScaling', {
            targetUtilizationPercent: 80,
        });
        webserverScalableTarget.scaleOnMemoryUtilization('WebServerMemoryScaling', {
            targetUtilizationPercent: 80,
        });
    }
}
