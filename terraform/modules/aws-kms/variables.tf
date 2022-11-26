variable "config" {
  description = "Map of configuration for KMS key"
  type = object({
    deletion_window_in_days = optional(string, 10)
    description             = optional(string, "Managed by Terraform")
    enable_key_rotation     = optional(bool, true)
    name                    = string
    policy                  = optional(string, null)
  })
}
