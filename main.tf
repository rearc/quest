terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 3.4.0"
    }
  }
  required_version = ">= 0.14.9"
  cloud {
    organization = "jonathanfinley"
    workspaces {
      name = "gh-actions"
    }
  }
}

