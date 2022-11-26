module "logs" {
  source = "../../modules/aws-cloudwatch-logs"

  config = {
    kms-key = var.config.kms-key-arn
    name    = var.config.cluster-name
  }
}
