# TODO: Move the Load Balancer to internal and remove this comment
# tfsec:ignore:aws-elb-alb-not-public
module "load-balancer" {
  source = "./modules/aws-loadbalancer"

  config = {
    cluster-name = local.project-name
    vpc          = module.network.vpc
    subnets      = module.network.subnets
  }
}
