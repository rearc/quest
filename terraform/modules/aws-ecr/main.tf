resource "aws_ecr_repository" "this" {
  encryption_configuration {
    encryption_type = var.config.kms-key-arn != null ? "KMS" : "AES256"
    kms_key         = var.config.kms-key-arn
  }

  image_scanning_configuration {
    scan_on_push = var.config.scan-images-on-push
  }

  image_tag_mutability = "IMMUTABLE"
  name                 = var.config.repository-name

  tags = {
    Name = var.config.repository-name
  }
}

# TODO: Add lifecycle policy
# TODO: Add replication configuration
