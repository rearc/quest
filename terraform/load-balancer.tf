# TODO: Move the Load Balancer to internal
# tfsec:ignore:aws-elb-alb-not-public 
module "load-balancer" {
  source = "./modules/aws-loadbalancer"

  config = {
    allowed-ingress-cidrs = var.cloudflare-config.cidrs
    certificate           = module.certificate.arn
    cluster-name          = local.project-name
    vpc                   = module.network.vpc
    subnets               = module.network.subnets
  }
}
