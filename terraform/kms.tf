module "encryption-key" {
  source = "./modules/aws-kms"

  config = {
    name   = local.project-name
    policy = data.aws_iam_policy_document.cloudwatch-kms.json
  }
}
