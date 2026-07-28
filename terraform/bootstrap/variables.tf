variable "aws_region" {
  description = "AWS region for the Terraform state bucket."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used when naming the Terraform state bucket."
  type        = string
  default     = "rearc-quest"
}

variable "aws_profile" {
  description = "AWS CLI profile (configured via IAM Identity Center / SSO) used for authentication."
  type        = string
  default     = "rearc-quest"
}
