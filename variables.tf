variable "aws_region" {
  default = "us-east-2"
}

variable "tags" {
  type = map

  default = {
    cost-center = "rearc-quest"
    owner = "scooke"
  }
}

variable "private_subnet_id" {
  type = string

  default = "subnet-0bc3bdf34d7ca72e1"
}

variable "public_subnet_id" {
  type = string

  default = "subnet-002ac4fd689e3f61a"
}

variable "vpc_id" {
  type = string

  default = "vpc-04797b76d86d6e1bf"
}
