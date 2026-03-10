output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.quest.dns_name
}

output "app_url_http" {
  description = "HTTP URL (redirects to HTTPS)"
  value       = "http://${aws_lb.quest.dns_name}"
}

output "app_url_https" {
  description = "HTTPS URL"
  value       = "https://${aws_lb.quest.dns_name}"
}

output "check_urls" {
  description = "Quest stage check endpoints"
  value = {
    index        = "https://${aws_lb.quest.dns_name}/"
    docker       = "https://${aws_lb.quest.dns_name}/docker"
    secret_word  = "https://${aws_lb.quest.dns_name}/secret_word"
    loadbalanced = "https://${aws_lb.quest.dns_name}/loadbalanced"
    tls          = "https://${aws_lb.quest.dns_name}/tls"
  }
}
