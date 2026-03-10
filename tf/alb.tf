# alb resources
resource "aws_lb" "quest" {
  name               = "quest-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "quest" {
  name        = "quest-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.quest.id
  target_type = "ip" # required for fargate

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

# HTTP to HTTPS redirect
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.quest.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS listener takes self signed acm cert
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.quest.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.quest.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quest.arn
  }
}
