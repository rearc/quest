locals {
  cloudwatch-log-group-name = var.config.cloudwatch-log-group-name != null ? var.config.cloudwatch-log-group-name : aws_cloudwatch_log_group.this.name
}
