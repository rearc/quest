# data "aws_default_tags" "this" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

# TODO: Pass in only the cloudwatch arns from modules/aws-ecs
data "aws_iam_policy_document" "cloudwatch-kms" {
  statement {
    sid = "EnableIAMUserPermissions"

    actions = [
      "kms:*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          data.aws_partition.current.partition,
          data.aws_caller_identity.current.account_id
        )
      ]
    }

    resources = ["*"]
  }

  statement {
    sid = "AllowCloudWatchLogs"

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    principals {
      type = "Service"
      identifiers = [
        format(
          "logs.%s.amazonaws.com",
          data.aws_region.current.name
        )
      ]
    }

    resources = ["*"]
  }
}
