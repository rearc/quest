resource "aws_alb" "this" {
  load_balancer_type = var.config.load-balancer-type
  name               = var.config.cluster-name

  security_groups = [
    aws_security_group.load-balancer.id
  ]

  subnets = var.config.subnets

  depends_on = [
    aws_security_group.load-balancer
  ]
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

resource "aws_lb_target_group" "https" {
  count = var.config.certificate != null ? 1 : 0

  name        = "${var.config.cluster-name}-https"
  port        = 443
  protocol    = "HTTPS"
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
  port              = 80
  protocol          = "HTTP"
}

resource "aws_lb_listener" "https" {
  count = var.config.certificate != null ? 1 : 0

  certificate_arn = var.config.certificate
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https[0].arn
  }

  load_balancer_arn = aws_alb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
}
