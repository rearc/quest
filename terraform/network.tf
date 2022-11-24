module "network" {
  source = "./modules/aws-network"

  config = {
    kms-key = module.encryption-key.arn
  }
}
