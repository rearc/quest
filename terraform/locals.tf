locals {
  # tags = { for k, v in data.aws_default_tags.this.tags : lower(k) => v }

  domain-name     = "benniemosher.dev" # TODO: terraform.workspace == "prod" ? "benniemosher.com" : "benniemosher.dev"
  sub-domain-name = "quest"            # TODO: terraform.workspace == "prod" ? "quest" : "${terraform.workspace}-quest"
  project-name    = "benniemosher-rearc-quest"
}
