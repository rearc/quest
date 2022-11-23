output "subnets" {
  description = "The subnet IDs created for the network."
  value = [
    aws_default_subnet.a.id,
    aws_default_subnet.b.id,
    aws_default_subnet.c.id,
  ]
}

output "vpc" {
  description = "The VPC ID created for the network."
  value       = aws_default_vpc.this.id
}
