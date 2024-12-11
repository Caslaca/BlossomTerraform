data "aws_availability_zones" "available_zones" {
    state = "available"
}

resource "aws_vpc" "blossom_vpc" {
    cidr_block           = var.vpc_cidr_block
    tags = {
      name = var.vpc_name
    }
}