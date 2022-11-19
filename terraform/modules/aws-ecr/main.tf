resource "aws_ecr_repository" "this" {
  name                 = var.config.repository-name
  image_tag_mutability = var.config.image-tag-mutability

  encryption_configuration {
    encryption_type = var.config.kms-key-arn != null ? "KMS" : "AES256"
    kms_key         = var.config.kms-key-arn != null ? local.kms-key-arn : null
  }

  image_scanning_configuration {
    scan_on_push = var.config.scan-images-on-push
  }

  tags = {
    "Name" = var.config.repository-name
  }
}

# TODO: Add lifecycle policy
# TODO: Add replication configuration
