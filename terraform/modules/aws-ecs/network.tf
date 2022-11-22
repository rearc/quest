
# TODO: Only create if vpc is null
# TODO: Secure the default VPC
resource "aws_default_vpc" "this" {}

# TODO: Use data resource to loop over available availability zones
# TODO: Only create if subnets is null
resource "aws_default_subnet" "a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "b" {
  availability_zone = "us-east-1b"
}

resource "aws_default_subnet" "c" {
  availability_zone = "us-east-1c"
}

resource "aws_security_group" "service" {
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.load-balancer.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
