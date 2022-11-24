# TODO: Use data resource to loop over available availability zones
resource "aws_default_subnet" "a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "b" {
  availability_zone = "us-east-1b"
}

resource "aws_default_subnet" "c" {
  availability_zone = "us-east-1c"
}
