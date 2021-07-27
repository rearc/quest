module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0.0"

  name        = "rearc-quest-alb"
  description = "Rearc Quest ALB SG"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_rules = ["http-80-tcp", "http-8080-tcp"]
  egress_rules  = ["all-all"]
}