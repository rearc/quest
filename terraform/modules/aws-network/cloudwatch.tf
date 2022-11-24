module "default-vpc-flow-logs" {
  source = "../../modules/aws-cloudwatch-logs"

  config = {
    kms-key = var.config.kms-key
    name    = "default-vpc-flow-logs"
  }
}
