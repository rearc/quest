terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_ecr_repository" "rearc-quest" {
  name = "rearc-quest" # Name of Repo
}

resource "aws_ecs_cluster" "rearc_quest" {
  name = "rearc_quest" # Name of Cluster
}

resource "aws_ecs_task_definition" "rearc_quest" {
  family = "rearc_quest" # Name of task
  container_definitions = <<DEFINITION
  [
    {
      "name": "rearc_quest",
      "image": "${aws_ecr_repository.rearc-quest.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "rearc_quest" {
  name            = "rearc_quest" # Service Name
  cluster         = "${aws_ecs_cluster.rearc_quest.id}" # Cluster
  task_definition = "${aws_ecs_task_definition.rearc_quest.arn}" # Task to Start
  launch_type     = "FARGATE"
  desired_count   = 2 

  load_balancer {
    target_group_arn = "${aws_lb_target_group.rearc_quest_target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.rearc_quest.family}"
    container_port   = 3000 # Specifying the container port
  }

  network_configuration {
    subnets = ["${aws_default_subnet.rearc_quest_a.id}", "${aws_default_subnet.rearc_quest_b.id}", "${aws_default_subnet.rearc_quest_c.id}"]
    assign_public_ip = true
    security_groups = ["${aws_security_group.rearc_quest_security_group.id}"]
  }
}

resource "aws_default_vpc" "rearc_quest_vpc" {
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "rearc_quest_a" {
  availability_zone = "us-east-2a"
}

resource "aws_default_subnet" "rearc_quest_b" {
  availability_zone = "us-east-2b"
}

resource "aws_default_subnet" "rearc_quest_c" {
  availability_zone = "us-east-2c"
}

resource "aws_alb" "rearc_quest_application_load_balancer" {
  name = "rearc-quest-lb-tf" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${aws_default_subnet.rearc_quest_a.id}",
    "${aws_default_subnet.rearc_quest_b.id}",
    "${aws_default_subnet.rearc_quest_c.id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.rearc_quest_load_balancer_security_group.id}"]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "rearc_quest_load_balancer_security_group" {
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_security_group" "rearc_quest_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.rearc_quest_load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_lb_target_group" "rearc_quest_target_group" {
  name        = "rearc-quest-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.rearc_quest_vpc.id}"
  health_check {
    matcher = "200,301,302"
    path = "/"
  }
}

resource "aws_lb_listener" "rearc_quest_listener" {
  load_balancer_arn = "${aws_alb.rearc_quest_application_load_balancer.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.rearc_quest_target_group.arn}" 
  }
}