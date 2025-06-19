variable "prefix" {
  type        = string
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_a_cidr" {
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_b_cidr" {
  type        = string
  default     = "10.0.2.0/24"
}
