variable "config" {
  description = "The config to create a DNS record in Cloudflare."
  type = object({
    dns-record = object({
      name     = string
      priority = optional(string, null)
      proxied  = optional(string, false)
      type     = optional(string, "CNAME")
      value    = string
    })
    root-domain-name = string
  })
}
