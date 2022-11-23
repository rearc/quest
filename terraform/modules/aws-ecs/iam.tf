resource "aws_iam_role" "ecs-task-execution" {
  assume_role_policy = data.aws_iam_policy_document.ecs-task-execution.json
  name               = "ecs-task-execution"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs-task-execution.name
}
