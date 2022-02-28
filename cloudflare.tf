provider "cloudflare" {
  email = var.cf_email
  api_key = var.cf_api
}

resource "cloudflare_record" "rearc-quest-aws" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "rearc-quest-aws"
  value   = "${aws_alb.rearc_quest_application_load_balancer.dns_name}"
  type    = "CNAME"
  proxied = false
}