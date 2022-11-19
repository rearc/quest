locals {
  # TODO: Switch ternary when kms key made in this module
  # kms-key-arn = var.config.kms-key-arn ? aws_kms_alias.target_key_arn : var.config.kms-key-arn
  kms-key-arn = var.config.kms-key-arn != null ? var.config.kms-key-arn : "*"

  cloudwatch-log-group-name = var.config.cloud-watch-log-group-name != null ? var.config.cloud-watch-log-group-name : aws_cloudwatch_log_group.this.name
}
