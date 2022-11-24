module "certificate" {
  source = "./modules/aws-acm"

  config = {
    certificate-domain = "${local.sub-domain-name}.${local.domain-name}"
    root-domain-name   = local.domain-name
    subject-alternative-names = [
      "*.${local.domain-name}"
    ]
  }
}
