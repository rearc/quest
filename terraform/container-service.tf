module "container-service" {
  source = "./modules/aws-ecs"

  config = {
    cluster-name = "benniemosher-rearc-quest"
    image-url    = module.container-registry.url
  }
}

output "dns" {
  value = module.container-service.alb-dns
}
