module "load-balancer" {
  source = "./modules/aws-loadbalancer"

  config = {
    cluster-name = "benniemosher-rearc-quest"
    vpc          = module.network.vpc
    subnets      = module.network.subnets
  }
}
