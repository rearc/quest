# TODO: Dynamically loop over subnets
resource "aws_alb" "this" {
  load_balancer_type = var.config.load-balancer-type
  name               = var.config.cluster-name

  security_groups = [
    aws_security_group.load-balancer.id
  ]

  subnets = var.config.subnets
}

resource "aws_security_group" "load-balancer" {
  description = "All egress traffic and all ingress on port 80 for the Load Balancer."
  name        = "load-balancer"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "All egress traffic"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "All ingress on port 80 for the Load Balancer."
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
}

resource "aws_lb_target_group" "this" {
  name        = var.config.cluster-name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.config.vpc


  depends_on = [
    aws_alb.this
  ]
}

resource "aws_lb_listener" "this" {
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  load_balancer_arn = aws_alb.this.arn
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_security_group" "service" {
  description = "Allow all egress traffic and ingress from the Load Balancer."
  name        = "ecs-service-load-balancer"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "All all egress traffic"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    description     = "Allow all ingress from Load Balancer security group."
    from_port       = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.load-balancer.id}"]
    to_port         = 0
  }
}
