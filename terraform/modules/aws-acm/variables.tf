variable "config" {
  description = "The config to create a certificate and validation records with."
  type = object({
    certificate-domain              = optional(string, null)
    root-domain-name                = string
    subject-alternative-names       = optional(list(string), [])
    transparency-logging-preference = optional(string, "ENABLED")
    validation-method               = optional(string, "DNS")
  })
}

