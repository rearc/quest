resource "aws_iam_role" "ecs-task-execution" {
  name               = "ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs-task-execution.json
}

