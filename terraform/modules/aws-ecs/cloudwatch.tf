resource "aws_cloudwatch_log_group" "this" {
  kms_key_id = var.config.kms-key-arn
  name       = var.config.cluster-name

  tags = {
    "Name" = var.config.cluster-name
  }
}
