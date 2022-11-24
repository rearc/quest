resource "aws_cloudwatch_log_group" "this" {
  kms_key_id = var.config.kms-key-arn
  name       = var.config.cluster-name

  tags = {
    Name = var.config.cluster-name
  }
}

resource "aws_cloudwatch_log_stream" "this" {
  log_group_name = aws_cloudwatch_log_group.this.name
  name           = var.config.cluster-name

  depends_on = [
    aws_cloudwatch_log_group.this
  ]
}
