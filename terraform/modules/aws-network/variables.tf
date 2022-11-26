variable "config" {
  description = "The config to create the ECS cluster with."
  type = object({
    kms-key = string
  })
}
