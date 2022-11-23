resource "cloudflare_record" "this" {
  name     = var.config.dns-record.name
  priority = var.config.dns-record.priority
  proxied  = var.config.dns-record.proxied
  type     = var.config.dns-record.type
  value    = var.config.dns-record.value
  zone_id  = data.cloudflare_zones.this.zones[0].id
}

