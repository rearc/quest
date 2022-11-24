module "container-registry" {
  source = "./modules/aws-ecr"

  config = {
    repository-name = local.project-name
  }
}
