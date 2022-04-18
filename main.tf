terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc_name" {
  source = "./vpc/"
}

module "ec2_name" {
  source = "./ec2"
  //vpc_id = module.vpc_name.vpc_name

}


