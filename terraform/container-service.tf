module "container-service" {
  source = "./modules/aws-ecs"

  config = {
    cluster-name = "benniemosher-rearc-quest"
    environment = [
      {
        name  = "SECRET_WORD"
        value = "Midi-chlorians"
      }
    ]
    image-url                  = module.container-registry.url
    load-balancer-target-group = module.load-balancer.load-balancer-target-group
    ecs-security-group         = module.load-balancer.ecs-security-group
    subnets                    = module.network.subnets
    vpc                        = module.network.vpc
  }
}
