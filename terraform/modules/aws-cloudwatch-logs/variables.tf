variable "config" {
  description = "The config to create the Cloudwatch Log Group with."
  type = object({
    kms-key = optional(string, null)
    name    = string
  })
}
