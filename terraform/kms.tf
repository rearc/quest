module "encryption-key" {
  source = "./modules/aws-kms"

  config = {
    name = local.project-name
  }
}
