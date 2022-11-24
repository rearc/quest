output "ecs-security-group" {
  description = "The security group ID for the ECS service to use."
  value       = aws_security_group.service.id
}

output "load-balancer-target-group" {
  description = "The target group for the load balancer."
  value       = aws_lb_target_group.this.arn
}

output "load-balancer-dns" {
  description = "The Load Balancer DNS name to reach the deployed web app."
  value       = aws_alb.this.dns_name
}
