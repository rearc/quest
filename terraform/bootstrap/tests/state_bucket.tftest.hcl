mock_provider "aws" {}

run "state_bucket_has_versioning_enabled" {
  command = plan

  assert {
    condition     = aws_s3_bucket_versioning.terraform_state.versioning_configuration[0].status == "Enabled"
    error_message = "Terraform state bucket must have versioning enabled so state history can be recovered."
  }
}

run "state_bucket_expires_noncurrent_versions" {
  command = plan

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.terraform_state.rule[0].noncurrent_version_expiration[0].noncurrent_days == 90
    error_message = "Terraform state bucket must expire noncurrent versions so version history doesn't grow unbounded."
  }
}

run "state_bucket_blocks_public_access" {
  command = plan

  assert {
    condition     = aws_s3_bucket_public_access_block.terraform_state.block_public_acls == true
    error_message = "Terraform state bucket must block public ACLs."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.terraform_state.block_public_policy == true
    error_message = "Terraform state bucket must block public bucket policies."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.terraform_state.ignore_public_acls == true
    error_message = "Terraform state bucket must ignore public ACLs set on existing objects."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.terraform_state.restrict_public_buckets == true
    error_message = "Terraform state bucket must restrict public bucket access."
  }
}

run "state_bucket_uses_server_side_encryption" {
  command = plan

  assert {
    condition     = one(aws_s3_bucket_server_side_encryption_configuration.terraform_state.rule).apply_server_side_encryption_by_default[0].sse_algorithm == "AES256"
    error_message = "Terraform state bucket must use SSE-AES256 encryption by default."
  }
}

run "state_bucket_name_uses_project_prefix" {
  command = plan

  variables {
    project_name = "rearc-quest"
  }

  assert {
    condition     = startswith(aws_s3_bucket.terraform_state.bucket, "rearc-quest-tfstate-")
    error_message = "State bucket name must start with '<project_name>-tfstate-'."
  }
}
