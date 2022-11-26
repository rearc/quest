# TODO: Secure the default VPC
resource "aws_default_vpc" "this" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_flow_log" "default-vpc" {
  iam_role_arn    = aws_iam_role.vpc-flow-logs.arn
  log_destination = module.default-vpc-flow-logs.log-group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_default_vpc.this.id
}
