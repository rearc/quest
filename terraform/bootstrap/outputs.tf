output "state_bucket_name" {
  description = "Name of the S3 bucket that holds Terraform state for the main stack."
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_region" {
  description = "Region the Terraform state bucket lives in."
  value       = var.aws_region
}
