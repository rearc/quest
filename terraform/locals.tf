locals {
  tags = { for k, v in data.aws_default_tags.this.tags : lower(k) => v }
}
