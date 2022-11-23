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
    image-url = module.container-registry.url
    subnets   = module.network.subnets
    vpc       = module.network.vpc
  }
}

output "dns" {
  value = module.container-service.alb-dns
}
