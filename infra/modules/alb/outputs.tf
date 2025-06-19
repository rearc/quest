output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.alb.zone_id
}

output "asg_name" {
  value = aws_autoscaling_group.web-server-asg.name
}