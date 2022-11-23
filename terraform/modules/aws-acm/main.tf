resource "aws_acm_certificate" "this" {
  domain_name = try(var.config.certificate-domain, var.config.root-domain-name)

  lifecycle {
    create_before_destroy = true
  }

  options {
    certificate_transparency_logging_preference = var.config.transparency-logging-preference
  }

  subject_alternative_names = var.config.subject-alternative-names

  tags = {
    "Name" = try(var.config.certificate-domain, var.config.root-domain-name)
  }

  validation_method = var.config.validation-method
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn

  validation_record_fqdns = [for n in null_resource.wait : trim(n.triggers.name, ".")]

  depends_on = [
    null_resource.wait,
    module.validation-dns-records,
    aws_acm_certificate.this,
  ]
}

resource "null_resource" "wait" {
  count = length(aws_acm_certificate.this.domain_validation_options)

  triggers = {
    cert_id = aws_acm_certificate.this.id
    name    = tolist(aws_acm_certificate.this.domain_validation_options)[count.index].resource_record_name
    record  = tolist(aws_acm_certificate.this.domain_validation_options)[count.index].resource_record_value
    type    = tolist(aws_acm_certificate.this.domain_validation_options)[count.index].resource_record_type
  }

  depends_on = [
    aws_acm_certificate.this
  ]
}

module "validation-dns-records" {
  count = length(null_resource.wait)

  source = "../../modules/cloudflare-dns-record"

  config = {
    dns-record = {
      name  = trim(null_resource.wait[count.index].triggers.name, ".")
      type  = null_resource.wait[count.index].triggers.type
      value = trim(null_resource.wait[count.index].triggers.record, ".")
    }

    root-domain-name = var.config.root-domain-name
  }
}
