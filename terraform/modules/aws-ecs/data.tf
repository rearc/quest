data "aws_region" "current" {}

data "aws_iam_policy_document" "ecs-task-execution" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
