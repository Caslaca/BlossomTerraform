terraform {
  required_version = ">= 0.12.0"
  backend "local" {
    path = "../terraform-local-state/default/terraform.tfstate"#<- Change this to your profile
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  region = "us-west-1"
  profile = "default" #<- Change this to your profile
}

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "subnets" {
  vpc_id = "${data.aws_vpc.default_vpc.id}"
}

data "aws_security_groups" "default_vpc_security_groups" {
  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.default_vpc.id}"]
  }
}
