module "container-service" {
  source = "./modules/aws-ecs"

  config = {
    cluster-name       = local.project-name
    ecs-security-group = module.load-balancer.ecs-security-group
    environment = [
      {
        name  = "SECRET_WORD"
        value = "Midi-chlorians"
      }
    ]
    image-url                  = module.container-registry.url
    load-balancer-target-group = module.load-balancer.load-balancer-target-group
    subnets                    = module.network.subnets
    vpc                        = module.network.vpc
  }
}
