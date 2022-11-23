data "aws_region" "current" {}

data "aws_iam_policy_document" "ecs-task-execution" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}
