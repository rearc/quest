data "aws_route53_zone" "laiello" {
  name         = "laiello.com."
  private_zone = false
}

resource "aws_route53_record" "rearc_quest" {
  zone_id = data.aws_route53_zone.laiello.zone_id
  name    = "rearc-quest.${data.aws_route53_zone.laiello.name}"
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "rearc_quest" {
  domain_name       = "rearc-quest.${data.aws_route53_zone.laiello.name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.rearc_quest.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.laiello.zone_id
}

resource "aws_acm_certificate_validation" "rearc_quest" {
  certificate_arn         = aws_acm_certificate.rearc_quest.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}