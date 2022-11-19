module "container-registry" {
  source = "./modules/aws-ecr"

  config = {
    repository-name = "benniemosher-rearc-quest"
  }
}
