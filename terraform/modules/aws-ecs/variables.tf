variable "config" {
  description = "The config to create the ECS cluster with."
  type = object({
    cluster-name                   = string
    kms-key-arn                    = optional(string, null)
    logging-command-configuration  = optional(string, "OVERRIDE")
    cloud-watch-encryption-enabled = optional(bool, true)
    cloud-watch-log-group-name     = optional(bool, null)
  })
}
