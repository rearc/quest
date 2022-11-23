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
  }
}

output "dns" {
  value = module.container-service.alb-dns
}
