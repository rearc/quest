module "container-service" {
  source = "./modules/aws-ecs"

  config = {
    cluster-name = "benniemosher-rearc-quest"
  }
}
