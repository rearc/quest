resource "aws_ecs_cluster" "this" {
  name = var.config.cluster-name

  configuration {
    execute_command_configuration {
      kms_key_id = var.config.kms-key-arn
      logging    = var.config.logging-command-configuration

      log_configuration {
        cloud_watch_encryption_enabled = var.config.cloudwatch-encryption-enabled
        cloud_watch_log_group_name     = module.logs.log-group-name
      }
    }
  }

  dynamic "setting" {
    for_each = var.config.cluster-settings
    iterator = setting

    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = var.config.cluster-name
  }
}

resource "aws_ecs_task_definition" "this" {
  family = var.config.cluster-name
  # TODO: Make this use a task-definition.tfpl file and check for one being passed in
  container_definitions = jsonencode([
    {
      name = var.config.cluster-name
      # image     = "${var.config.cluster-name}:latest"
      image     = "${var.config.image-url}:latest"
      cpu       = var.config.task-definition-cpu
      memory    = var.config.task-definition-memory
      essential = true
      portMappings = [
        {
          containerPort = var.config.task-definition-container-port
          hostPort      = var.config.task-definition-host-port
        }
      ]
      environment = var.config.environment
    },
  ])
  requires_compatibilities = [var.config.launch-type]
  network_mode             = var.config.task-definition-network-mode
  memory                   = var.config.task-definition-memory
  cpu                      = var.config.task-definition-cpu
  execution_role_arn       = aws_iam_role.ecs-task-execution.arn
}

resource "aws_ecs_service" "this" {
  name            = var.config.cluster-name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = var.config.launch-type
  desired_count   = var.config.ecs-service-count

  load_balancer {
    target_group_arn = var.config.load-balancer-target-group
    container_name   = aws_ecs_task_definition.this.family
    container_port   = 3000
  }

  network_configuration {
    subnets          = var.config.subnets
    assign_public_ip = var.config.assign-public-ip
    # TODO: try(var.config.security-groups)
    security_groups = [
      var.config.ecs-security-group
    ]
  }
}
