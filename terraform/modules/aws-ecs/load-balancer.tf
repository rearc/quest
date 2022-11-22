# TODO: Dynamically loop over subnets
resource "aws_alb" "this" {
  load_balancer_type = var.config.load-balancer-type
  name               = var.config.cluster-name

  security_groups = [
    aws_security_group.load-balancer.id
  ]

  subnets = [
    aws_default_subnet.a.id,
    aws_default_subnet.b.id,
    aws_default_subnet.c.id,
  ]
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

resource "aws_lb_target_group" "this" {
  name        = var.config.cluster-name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.this.id
  depends_on  = [aws_alb.this]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_alb.this.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
