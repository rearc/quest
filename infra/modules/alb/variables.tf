variable "prefix" {
  type        = string
  description = "Environment prefix (e.g., dev, prod)"
}

variable "region" {
  type        = string
  description = "AWS region where resources will be deployed"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for web servers (e.g., t2.micro)"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instances"
}
variable "secret_word" {
  type        = string
  description = "Environment variable passed to the application container"
}

variable "docker_image" {
  type        = string
  description = "Docker image for the application (e.g., aditya/quotes-app)"
}

variable "docker_image_tag" {
  type        = string
  description = "Docker image tag (e.g., latest)"
}

variable "key_name" {
  type        = string
  description = "AWS EC2 key pair name to allow SSH access"
}

variable "domain_name" {
  type        = string
  description = "Primary domain name (e.g., codexplorer.tech)"
}

variable "alternate_domain_names" {
  type        = list(string)
  default     = []
  description = "Alternate domain names for SSL (e.g., www.codexplorer.tech)"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the validated ACM certificate for HTTPS"
}
