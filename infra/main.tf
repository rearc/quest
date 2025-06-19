module "vpc" {
  source               = "./modules/vpc"
  prefix               = var.prefix
  region               = var.region
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_a_cidr = "10.0.1.0/24"
  public_subnet_b_cidr = "10.0.2.0/24"
}


# EC2 Module
module "ec2" {
  source        = "./modules/ec2"
  ami_id = var.ami_id
  prefix        = var.prefix
  region        = var.region
  instance_type = var.instance_type
  docker_image  = var.docker_image
  secret_word   = var.secret_word
  docker_image_tag = var.docker_image_tag
  depends_on = [
    module.vpc
  ]
}
module "alb" {
  source = "./modules/alb"
}
