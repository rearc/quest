resource "aws_kms_key" "this" {
  deletion_window_in_days = var.config.deletion_window_in_days
  description             = var.config.description
  enable_key_rotation     = var.config.enable_key_rotation
  policy                  = var.config.policy

  tags = {
    Name = var.config.name
  }
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.config.name}"
  target_key_id = aws_kms_key.this.key_id

  depends_on = [
    aws_kms_key.this
  ]
}
