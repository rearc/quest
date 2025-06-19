
# ALB Module
# This module sets up an Application Load Balancer, Security Groups,an Auto Scaling Group with a Launch Template for EC2 instances running Docker containers, It also creates a Route53 record for DNS resolution.



data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.prefix}/vpc/id"
}

data "aws_ssm_parameter" "subnet" {
  name = "/${var.prefix}/subnet/a/id"
}

data "aws_ssm_parameter" "subnet_b" {
  name = "/${var.prefix}/subnet/b/id"
}

locals {
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  subnet_a_id = data.aws_ssm_parameter.subnet.value
  subnet_b_id = data.aws_ssm_parameter.subnet_b.value
}


# Security Group for ALB - allows inbound HTTP & HTTPS traffic
resource "aws_security_group" "alb-sg" {
  vpc_id      = local.vpc_id
  name        = "${var.prefix}-alb-sg"
  description = "Security group for ALB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-alb-sg"
  }
}

# Security Group for EC2 instances
resource "aws_security_group" "web_server_sg" {
  vpc_id      = local.vpc_id
  name        = "${var.prefix}-web-server-sg"
  description = "Security group for web server"

  # Only ALB can reach EC2 on port 80
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  # SSH access for debugging (restrict in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-web-server-sg"
  }
}

# Store ALB security group ID in SSM
resource "aws_ssm_parameter" "alb_sg" {
  name  = "/${var.prefix}/alb/sg/id"
  value = aws_security_group.alb-sg.id
  type  = "String"
}



# Create the ALB
resource "aws_lb" "alb" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [local.subnet_a_id, local.subnet_b_id]

  tags = {
    Environment = var.prefix
  }
}

# Target group for the ALB
resource "aws_lb_target_group" "alb-tg" {
  name     = "${var.prefix}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.prefix}-alb-tg"
  }
}

# HTTP Listener to redirect to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
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

# HTTPS Listener to forward to target group
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}



# Launch template for EC2 instances running Docker container
resource "aws_launch_template" "web-server-lt" {
  name          = "${var.prefix}-lt"
  description   = "Launch template for web servers"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_server_sg.id]
  }

  user_data = base64encode(templatefile("${path.module}/setup.sh.tpl", {
    docker_image = "${var.docker_image}:${var.docker_image_tag}",
    secret_word  = var.secret_word
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix}-web-server"
    }
  }
}

# Auto Scaling Group with minimum 2 and maximum 3 instances
resource "aws_autoscaling_group" "web-server-asg" {
  name                = "${var.prefix}-asg"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 2
  vpc_zone_identifier = [local.subnet_a_id, local.subnet_b_id]
  target_group_arns   = [aws_lb_target_group.alb-tg.arn]

  launch_template {
    id      = aws_launch_template.web-server-lt.id
    version = "$Latest"
  }

  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "${var.prefix}-web-server"
    propagate_at_launch = true
  }
}



data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
