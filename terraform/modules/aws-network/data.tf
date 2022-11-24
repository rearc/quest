data "aws_iam_policy_document" "vpc-flow-logs" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.default-vpc.arn
    ]
  }
}

data "aws_iam_policy_document" "vpc-flow-logs-assume-role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}
