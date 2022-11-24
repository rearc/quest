module "load-balancer" {
  source = "./modules/aws-loadbalancer"

  config = {
    cluster-name = local.project-name
    vpc          = module.network.vpc
    subnets      = module.network.subnets
  }
}
