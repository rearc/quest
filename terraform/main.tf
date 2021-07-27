terraform {
  required_version = "~>1.0.3"

  backend "s3" {
    bucket = "laiello-terraform-tfstate"
    region = "us-east-1"
    key    = "rearc-quest"
    acl    = "bucket-owner-full-control"
  }

  required_providers {
    aws = {
      version = "~>3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}