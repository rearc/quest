# iam stuff
# note i create a deny all rule for the ecs task iam policy
# i also set it as the permission boundary for the role
# this prevents privesc
data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

# Execution role – used by the ECS agent to pull images and write logs
resource "aws_iam_role" "ecs_execution" {
  name               = "quest-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task role – used by the running container itself
data "aws_iam_policy_document" "quest_task" {
  statement {
    effect  = "Deny"
    actions = ["*"]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "quest_task" {
  name   = "quest-ecs-task-policy"
  policy = data.aws_iam_policy_document.quest_task.json
}

resource "aws_iam_role" "quest_task" {
  name                 = "quest-ecs-task-role"
  assume_role_policy   = data.aws_iam_policy_document.ecs_assume_role.json
  permissions_boundary = aws_iam_policy.quest_task.arn
}

resource "aws_iam_role_policy_attachment" "quest_task" {
  role       = aws_iam_role.quest_task.name
  policy_arn = aws_iam_policy.quest_task.arn
}
