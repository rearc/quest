resource "aws_iam_role" "ecs-task-execution" {
  name               = "ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs-task-execution.json
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution" {
  role       = aws_iam_role.ecs-task-execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
