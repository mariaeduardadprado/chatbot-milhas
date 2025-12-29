terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project         = var.name
      Environment     = var.environment
    }
    
  }
}

module "lambda" {
  source= "./modules/lambda"
  name= var.name
  environment= var.environment
  region = var.region
}
module "vpc" {
  source              = "./modules/vpc"
  name                = var.name
  environment         = var.environment
  cidr_block          = var.cidr_block
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  availability_zones  = var.availability_zones
}

