variable "aws-profile" {
  default     = "benniemosher-quest-sandbox"
  description = "The local AWS profile with access to the service account"
  type        = string
}

variable "region" {
  default     = "us-east-1"
  description = "The AWS region in which to stand up resources"
  type        = string
}
