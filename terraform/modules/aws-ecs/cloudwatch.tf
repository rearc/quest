resource "aws_cloudwatch_log_group" "this" {
  name = var.config.cluster-name

  tags = {
    "Name" = var.config.cluster-name
  }
}
