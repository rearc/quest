resource "aws_eip" "alb_ip" {
  vpc              = true
  public_ipv4_pool = "amazon"

  tags = var.tags
}

# checkov:skip=CKV_AWS_150:Allowing for easy delete
resource "aws_lb" "rearc_quest_alb" {
  name               = "rearc-quest-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [ var.public_subnet_id, var.public_subnet2_id ]
  security_groups    = [ aws_security_group.allow_tls.id ]

  drop_invalid_header_fields = true

  tags = var.tags
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}
