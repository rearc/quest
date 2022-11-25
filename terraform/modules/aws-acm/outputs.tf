output "arn" {
  description = "The arn of the certificate created."
  value       = aws_acm_certificate.this.arn
}
