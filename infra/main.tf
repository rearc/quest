
# VPC MODULE: Networking setup

module "vpc" {
  source               = "./modules/vpc"
  prefix               = var.prefix                         
  region               = var.region                         
  vpc_cidr             = var.vpc_cidr                       
  public_subnet_a_cidr = var.public_subnet_a_cidr           
  public_subnet_b_cidr = var.public_subnet_b_cidr           
}


# Route53 Zone Lookup

data "aws_route53_zone" "main" {
  name         = var.domain_name        
  private_zone = false
}


# KEY PAIR (EC2 SSH Access - generated)

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096                      
}

resource "aws_key_pair" "main_key" {
  key_name   = "${var.prefix}-key"                      #
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Store private key locally to use for SSH
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/${var.prefix}-private-key.pem"
  file_permission = "0400"
}


# ALB MODULE: Load balancer + ASG setup

module "alb" {
  source                 = "./modules/alb"
  prefix                 = var.prefix
  region                 = var.region
  instance_type          = var.instance_type
  ami_id                 = var.ami_id
  docker_image           = var.docker_image
  docker_image_tag       = var.docker_image_tag
  secret_word            = var.secret_word
  key_name               = aws_key_pair.main_key.key_name
  domain_name            = var.domain_name
  alternate_domain_names = var.alternate_domain_names
  acm_certificate_arn    = var.acm_certificate_arn

  depends_on = [module.vpc]     
}
