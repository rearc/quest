module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.78.0"

  name = "rearc-quest"
  cidr = "10.17.0.0/20"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]

  public_subnets        = ["10.17.0.0/24", "10.17.1.0/24", "10.17.2.0/24", "10.17.3.0/24", "10.17.4.0/24", "10.17.5.0/24"]
  private_subnets       = ["10.17.6.0/24", "10.17.7.0/24", "10.17.8.0/24", "10.17.9.0/24", "10.17.10.0/24", "10.17.11.0/24"]
  database_subnets      = ["10.17.12.0/24", "10.17.13.0/24", "10.17.14.0/24", "10.17.15.0/24"]
  private_subnet_suffix = "app"

  create_database_subnet_route_table = true
  create_database_nat_gateway_route  = true
  create_database_subnet_group       = false

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true
}