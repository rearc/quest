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
resource "aws_instance" "terraform_ec2_example" {
  ami           = "ami-094125af156557ca2"
  instance_type = "t2.micro"

  security_groups = [aws_security_group.test_rearc.name]
  key_name = "deepm1298"
  tags = {
    Name = "ExampleAppServerInstance1"
  
  }
}


resource "aws_instance" "terraform_ec2_example2" {
  ami           = "ami-094125af156557ca2"
  instance_type = "t2.micro"

  security_groups = [aws_security_group.test_rearc.name]
  key_name = "deepm1298"
  tags = {
    Name = "ExampleAppServerInstance2"
  
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