resource "aws_ecs_cluster" "this" {
  name = var.config.cluster-name

  configuration {
    execute_command_configuration {
      kms_key_id = local.kms-key-arn
      logging    = var.config.logging-command-configuration

      log_configuration {
        cloud_watch_encryption_enabled = var.config.cloud-watch-encryption-enabled
        cloud_watch_log_group_name     = local.cloudwatch-log-group-name
      }
    }
  }

  tags = {
    "Name" = var.config.cluster-name
  }
}

resource "aws_ecs_task_definition" "this" {
  family = var.config.cluster-name
  # TODO: Make this use a task-definition.tfpl file and check for one being passed in
  container_definitions = jsonencode([
    {
      name      = var.config.cluster-name
      image     = var.config.cluster-name
      cpu       = var.config.task-definition-cpu
      memory    = var.config.task-definition-memory
      essential = true
      portMappings = [
        {
          containerPort = var.config.task-definition-container-port
          hostPort      = var.config.task-definition-host-port
        }
      ]
    },
  ])
  requires_compatibilities = var.config.launch-type
  network_mode             = var.config.task-definition-network-mode
  memory                   = var.config.task-definition-memory
  cpu                      = var.config.task-definition-cpu
  execution_role_arn       = aws_iam_role.ecs-task-execution.arn
}


# TODO: Create an ECS Service
# TODO: Create a VPC
# TODO: Create an ALB
