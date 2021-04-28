terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "rearc-quest-infra-tf-state"
    key = "rearc-quest/prod/quest"
    dynamodb_table = "rearc-quest-infra-tf-state-locking"
    region = "us-east-2"
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_iam_policy" "ssm_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
