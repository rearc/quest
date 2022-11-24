resource "aws_iam_role" "vpc-flow-logs" {
  name = "vpc-flow-logs"

  assume_role_policy = data.aws_iam_policy_document.vpc-flow-logs-assume-role.json
}

resource "aws_iam_role_policy" "vpc-flow-logs" {
  name = "vpc-flow-logs"
  role = aws_iam_role.vpc-flow-logs.id

  policy = data.aws_iam_policy_document.vpc-flow-logs.json
}
