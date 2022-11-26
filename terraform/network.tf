# TODO: Remove this and fix error
# tfsec:ignore:aws-ec2-no-default-vpc
module "network" {
  source = "./modules/aws-network"

  config = {
    kms-key = module.encryption-key.arn
  }
}
