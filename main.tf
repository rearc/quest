terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "rearc-quest-infra-tf-state"
    key = "rearc-quest-infra/prod/tf-executor"
    dynamodb_table = "rearc-quest-infra-tf-state-locking"
    region = "us-east-2"
  }
}

provider "aws" {
  region = var.aws_region
}
