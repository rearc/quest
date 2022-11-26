variable "config" {
  description = "The config to create the ECR repository with."
  type = object({
    kms-key-arn         = optional(string, null)
    repository-name     = string
    scan-images-on-push = optional(bool, true)
  })
}

