# TLS / ACM
# Self-signed certificate generated locally and imported into ACM.
# This satisfies the /tls check without requiring a public domain.
# Reccomended tls cert validity is 47 days by 2029
# https://www.digicert.com/blog/tls-certificate-lifetimes-will-officially-reduce-to-47-days

resource "tls_private_key" "quest" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "quest" {
  private_key_pem = tls_private_key.quest.private_key_pem

  subject {
    common_name  = "quest.local"
    organization = "Quest"
  }

  # Valid for 47 days
  validity_period_hours = 1128

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "quest" {
  private_key      = tls_private_key.quest.private_key_pem
  certificate_body = tls_self_signed_cert.quest.cert_pem
}
