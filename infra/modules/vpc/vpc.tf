resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_ssm_parameter" "vpc" {
  name = "/${var.prefix}/vpc/id"
  value = "${aws_vpc.vpc.id}"
  type  = "String"
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_a_cidr
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.prefix}-public-subnet-a"
  }
}

resource "aws_ssm_parameter" "subnet_a" {
  name = "/${var.prefix}/subnet/a/id"
  value = "${aws_subnet.public_subnet_a.id}"
  type  = "String"
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_b_cidr
  availability_zone = "${var.region}b"
  tags = {
    Name = "${var.prefix}-public-subnet-b"
  }
}

resource "aws_ssm_parameter" "subnet_b" {
  name = "/${var.prefix}/subnet/b/id"
  value = "${aws_subnet.public_subnet_b.id}"
  type  = "String"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_route_table" "public_subnet_routes" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.prefix}-public-subnet-routes"
  }
}

resource "aws_route_table_association" "public_subnet_routes_assn_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_subnet_routes.id
}

resource "aws_route_table_association" "public_subnet_routes_assn_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_subnet_routes.id
}
