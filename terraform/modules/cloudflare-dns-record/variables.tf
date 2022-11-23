variable "config" {
  description = "The config to create a DNS record in Cloudflare."
  type = object({
    root-domain-name = string
    dns-record = object({
      name     = string
      priority = optional(string, null)
      proxied  = optional(string, false)
      type     = optional(string, "CNAME")
      value    = string
    })
  })
}
