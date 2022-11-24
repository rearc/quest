# TODO: Move the Load Balancer to internal
# tfsec:ignore:aws-elb-alb-not-public tfsec:ignore:aws-ec2-no-public-ingress-sgr
module "load-balancer" {
  source = "./modules/aws-loadbalancer"

  config = {
    allowed-ingress-cidrs = var.cloudflare-config.cidrs
    cluster-name          = local.project-name
    vpc                   = module.network.vpc
    subnets               = module.network.subnets
  }
}
