
resource "aws_ecr_repository" "rearc_quest" {
  name                 = "rearc-quest"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}