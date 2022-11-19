locals {
  # TODO: Switch ternary when kms key made in this module
  # kms-key-arn = var.config.kms-key-arn ? aws_kms_alias.target_key_arn : var.config.kms-key-arn
  kms-key-arn = var.config.kms-key-arn != null ? "*" : var.config.kms-key-arn
}
