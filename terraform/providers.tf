terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.40"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
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

provider "cloudflare" {
  # account_id = var.cloudflare-config.account-id
  api_token = var.cloudflare-config.api-token
}
