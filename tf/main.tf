# ecs resources
resource "aws_ecs_cluster" "quest" {
  name = "quest-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_task_definition" "quest" {
  family                   = "quest"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.quest_task.arn

  container_definitions = jsonencode([
    {
      name      = "quest"
      image     = "ghcr.io/koalasec/quest:@sha256:8ff6d588428461b42f8798e69ba87ab5a1e09064a5e2215540f4bf5620b8d00d"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "SECRET_WORD"
          value = "TwelveFactor"
        }
      ]

    }
  ])
}

resource "aws_ecs_service" "quest" {
  name            = "quest-service"
  cluster         = aws_ecs_cluster.quest.id
  task_definition = aws_ecs_task_definition.quest.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.quest.arn
    container_name   = "quest"
    container_port   = "3000"
  }

  depends_on = [
    aws_lb_listener.http,
    aws_lb_listener.https,
    aws_iam_role_policy_attachment.ecs_execution,
  ]
}
