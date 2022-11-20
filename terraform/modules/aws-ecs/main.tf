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

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.target_group.arn
  #   container_name   = aws_ecs_task_definition.quest_task.family
  #   container_port   = 3000
  # }

  network_configuration {
    # subnets          = var.config.subnets
    # TODO: Try var.config.subnets
    subnets = [
      aws_default_subnet.default_subnet_a.id,
      aws_default_subnet.default_subnet_b.id,
      aws_default_subnet.default_subnet_c.id
    ]
    assign_public_ip = var.config.assign-public-ip
    # TODO: try(var.config.security-groups)
    security_groups = [
      aws_security_group.service.id
    ]
  }
}

# TODO: Only create if vpc is null
# TODO: Secure the default VPC
resource "aws_default_vpc" "this" {}

# TODO: Use data resource to loop over available availability zones
# TODO: Only create if subnets is null
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-1b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "us-east-1c"
}

resource "aws_security_group" "service" {
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.load-balancer.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "load-balancer" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# TODO: Create an ALB
