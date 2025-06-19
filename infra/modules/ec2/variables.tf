variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
  
}
variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instance"
  default     = "t2.medium"
}   

variable "prefix" {
  type        = string
  description = "Environment prefix"
  
}

variable "region" {
  type        = string
  description = "AWS region"
  
  
}
variable "secret_word" {
  type        = string
  description = "Secret word for the application"

}
variable "docker_image" {
  type        = string
  description = "Docker image for the web-app application"
  
}
variable "docker_image_tag" {
  description = "Docker image tag for the web-app application"
}