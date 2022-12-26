terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}
provider "aws" {
  region  = "us-west-2"
}


resource "aws_lb" "test" {
    name = "rearc_test_load_balancer"

    load_balancer_type = "application"
    vpc_id="vpc-0f24500d19b221c2a"
    subnets=["subnet-0248f24c0386773e6 - us-west-2c","subnet-03bb8032907073557 - us-west-2a","subnet-08bb77636bb9992a4 - us-west-2b"]
    security_groups=[aws_security_group.test_rearc.name]

    target_groups = [
        
        {
            name_prefix = "target_rearc_test"
            backend_protocol = "HTTP"
            backend_port = 80
            target_type = "instance"
            targets = [
                {
                    target_id = "i-07894f95c59ac4cd7"
                    port = 3000
                    health_check = {
                        path = "/secret_word"
                    }
                }
            ]
        },
        {
            name_prefix = "target_rearc_test"
            backend_protocol = "HTTPS"
            backend_port = 443
            target_type = "instance"
            targets = [
                {
                    target_id = "i-07894f95c59ac4cd7"
                    port = 3000
                    health_check = {
                        path = "/secret_word"
                    }
                }
            ]
        }
    ]

    http_tcp_listeners = [
        {
            port = 80
            protocol = "HTTP"
            action_type = "forward"
            forward = {
                port = "3000"
                protocol = "TCP"
                status_code = 200
            }

        }
    ]

    https_tcp_listeners = [
        {
            port = 443
            protocol = "HTTPS"
            certificate_arn = "arn:aws:iam::726952267345:server-certificate/certificate"
            action_type = "forward"
            forward = {
                port = "3000"
                protocol = "TCP"
                status_code = 200
            }
        }
    ]
       tags = {
       
        deployment = "terraform"
        region = "us-west-2"
    }
   }


   
resource "aws_security_group" "test_rearc" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      =  "vpc-0f24500d19b221c2a"

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 3000
    to_port          = 3000
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

  tags = {
    Name = "test_rearc"
  }
}


