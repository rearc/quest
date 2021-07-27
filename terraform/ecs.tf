module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 3.0"

  name               = "rearc-quest"
  container_insights = true
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
    }
  ]
}

resource "aws_lb_target_group" "service_target_group" {
  name                 = module.alb.target_group_names[0]
  port                 = 3000
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 30
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = module.alb.http_tcp_listener_arns[0]
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_target_group.arn
  }

  condition {
    http_request_method {
      values = ["GET"]
    }
  }
}

resource "aws_kms_key" "ecs" {
  description             = "Rearc Quest ECS KMS key"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = <<EOF
	{
 "Version": "2012-10-17",
    "Id": "encrypt-log-groups",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.${data.aws_region.current.name}.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
            "Resource": "*",
            "Condition": {
                "ArnEquals": {
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
                }
            }
        }
    ]
	}
	EOF
}

resource "aws_kms_alias" "ecs" {
  name          = "alias/rearc-quest"
  target_key_id = aws_kms_key.ecs.key_id
}

module "app_ecs_service" {
  source  = "trussworks/ecs-service/aws"
  version = "6.3.0"

  name        = "rearc-quest"
  environment = "prod"

  kms_key_id = aws_kms_key.ecs.arn

  ecs_cluster = {
    arn  = module.ecs.ecs_cluster_arn
    name = module.ecs.ecs_cluster_name
  }
  ecs_vpc_id            = module.vpc.vpc_id
  ecs_subnet_ids        = module.vpc.private_subnets
  logs_cloudwatch_group = "/ecs/rearc-quest-prod"
  tasks_desired_count   = 1
  ecs_use_fargate       = true
  fargate_platform_version = "1.3.0"

  associate_alb      = true
  alb_security_group = module.alb_sg.security_group_id
  container_definitions = templatefile("${path.module}/templates/container_definitions.json.tpl", {
    region   = data.aws_region.current.name
    appName  = "rearc-quest-prod",
    appImage = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/rearc-quest"
    secretWord = var.secret_word
  })

  ecr_repo_arns = [
    "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/rearc-quest"
  ]

  lb_target_groups = [
    {
      container_port              = 3000
      container_health_check_port = 3000
      lb_target_group_arn         = aws_lb_target_group.service_target_group.arn
    }
  ]
}