data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["self", "amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "rearc_quest_ec2" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = false
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [ aws_security_group.allow_from_alb.id ]
  subnet_id                   = var.private_subnet_id

  metadata_options {
    http_endpoint = disabled
  }

  user_data = data.cloudinit_config.quest_cloudinit.rendered
}

resource "aws_security_group" "allow_from_alb" {
  name        = "allow_3000_from_alb"
  description = "Allow inbound traffic from ALB on port 3000"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Traffic from ALB SG"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    security_groups  = [ aws_security_group.allow_tls.id ]
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

resource "aws_lb_target_group" "ec2_target_group" {
  name        = "rearc-quest-ec2-target"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  tags = var.tags
}


resource "aws_lb_target_group_attachment" "ec2_target_group_attachment" {
  target_group_arn = aws_lb_target_group.ec2_target_group.arn
  target_id        = aws_instance.rearc_quest_ec2.id
}

locals {
  cloud_config_config = <<-END
    #cloud-config
    ${jsonencode({
      write_files = [
        {
          path        = "/lib/systemd/system/quest.service"
          permissions = "0555"
          owner       = "ec2-user:ec2-user"
          encoding    = "b64"
          content     = filebase64("${path.module}/quest.service")
        },
      ]
    })}
  END
}

data "cloudinit_config" "quest_cloudinit" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"
    content      = local.cloud_config_config
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "install-node.sh"
    content  = <<-EOF
    #! /bin/bash
    curl -sL https://rpm.nodesource.com/setup_10.x | bash
    yum update -y
    yum install nodejs git

    git clone https://github.com/rearc/quest.git /home/ec2-user/quest
    chown -R ec2-user:ec2-user /home/ec2-user/quest

    systemctl daemon-reload
    systemctl enable quest
    EOF
  }
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2_ssm_profile"
  role = aws_iam_role.ssm_role.name
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_role" {
  name                = "rearc-quest-ssm-role"
  assume_role_policy  = data.aws_iam_policy_document.instance_assume_role_policy.json
  managed_policy_arns = [data.aws_iam_policy.ssm_policy.arn]
}
