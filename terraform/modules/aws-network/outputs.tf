output "subnets" {
  description = "The subnet IDs created for the network."
  value       = [for az in aws_default_subnet.this : az.id]
}

output "vpc" {
  description = "The VPC ID created for the network."
  value       = aws_default_vpc.this.id
}
