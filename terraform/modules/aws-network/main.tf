resource "aws_default_subnet" "this" {
  for_each = toset(data.aws_availability_zones.available.names)

  availability_zone = each.value
}
