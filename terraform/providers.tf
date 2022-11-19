terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.40"
    }
  }

  required_version = "~> 1.3"
}

provider "aws" {
  profile = var.aws-profile
  region  = var.region

  default_tags {
    tags = {
      Application = "Quest"
      Comment     = "Made by benniemosher via Terraform."
      Company     = "Rearc"
    }
  }
}
