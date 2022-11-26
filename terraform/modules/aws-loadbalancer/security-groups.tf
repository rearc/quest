resource "aws_security_group" "load-balancer" {
  description            = "All ingress on port 80 for the Load Balancer."
  name                   = "load-balancer"
  revoke_rules_on_delete = true

  tags = {
    Name = "load-balancer"
  }
}

resource "aws_security_group_rule" "http-ingress" {
  cidr_blocks       = var.config.allowed-ingress-cidrs
  description       = "All ingress on port 80 for the Load Balancer."
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.load-balancer.id
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "https-ingress" {
  count = var.config.certificate != null ? 1 : 0

  cidr_blocks       = var.config.allowed-ingress-cidrs
  description       = "All ingress on port 443 for the Load Balancer."
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.load-balancer.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group" "service" {
  description            = "Allow all ingress from Load Balancer security group."
  name                   = "ecs-service-load-balancer"
  revoke_rules_on_delete = true

  ingress {
    description     = "Allow all ingress from Load Balancer security group."
    from_port       = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.load-balancer.id}"]
    to_port         = 0
  }

  tags = {
    Name = "ecs-service-load-balancer"
  }
}
