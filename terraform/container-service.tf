module "container-service" {
  source = "./modules/aws-ecs"

  config = {
    cluster-name = "benniemosher-rearc-quest"
  }
}

output "dns" {
  value = module.container-service.alb-dns
}
