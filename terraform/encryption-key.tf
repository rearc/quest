# TODO: Remove bam from name
module "encryption-key" {
  source = "./modules/aws-kms"

  config = {
    name   = "${local.project-name}-bam"
    policy = data.aws_iam_policy_document.cloudwatch-kms.json
  }
}
