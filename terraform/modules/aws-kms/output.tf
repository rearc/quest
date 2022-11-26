output "arn" {
  description = "The ARN of the KMS key created."
  value       = aws_kms_alias.this.target_key_arn
}

output "id" {
  description = "The ID of the KMS key created."
  value       = aws_kms_key.this.key_id
}
