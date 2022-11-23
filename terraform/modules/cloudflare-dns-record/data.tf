data "cloudflare_zones" "this" {
  filter {
    name = var.config.root-domain-name
  }
}
