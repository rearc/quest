resource "aws_eip" "alb_ip" {
  vpc              = true
  public_ipv4_pool = "amazon"

  tags = var.tags
}

#tfsec:ignore:AWS005
resource "aws_lb" "rearc_quest_alb" {
  name               = "rearc-quest-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [ var.public_subnet_id, var.public_subnet2_id ]
  security_groups    = [ aws_security_group.allow_tls.id ]

  drop_invalid_header_fields = true

  access_logs {
    bucket  = aws_s3_bucket.access_logs.id
    prefix  = "rearc-quest"
    enabled = true
  }

  # checkov:skip=CKV_AWS_150:Allowing for easy delete
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

#tfsec:ignore:AWS077
resource "aws_s3_bucket" "access_logs" {
  bucket = "rearc-quest-access-logs"
  acl    = "log-delivery-write"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = AES256
      }
    }
  }


  # checkov:skip=CKV_AWS_21:Not versioning logs
  # checkov:skip=CKV_AWS_18:Not doing access logs for the access logs bucket
  # checkov:skip=CKV_AWS_52:Not doing mfa delete so I can delete this easier later
  # checkov:skip=CKV_AWS_144:Not enabling cross-region because we don't care so much about logs
  # checkov:skip=CKV_AWS_145:Not encrypting with KMS
  tags = var.tags
}
