variable "config" {
  description = "The config to create a DNS record in Cloudflare."
  type = object({
    root-domain-name = string
    # dns-record       = list(any)
  })
}
