output "alb-dns" {
  description = "The ALB DNS name to reach the deployed web app."
  value       = aws_alb.this.dns_name
}
