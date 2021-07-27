module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "rearc-quest"

  load_balancer_type = "application"
  internal           = false

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.alb_sg.security_group_id]

  #   access_logs = {
  #     bucket = aws_s3_bucket.access_logs.id
  #     prefix = "rearc-quest"
  #   }

  target_groups = [
    {
      name_prefix      = "ecs-"
      backend_protocol = "HTTP"
      backend_port     = 3000
      target_type      = "ip"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
    {
      port               = 8080
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}