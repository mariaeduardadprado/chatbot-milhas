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

module "security_groups" {
  source         = "./modules/security-groups"
  name           = var.name
  vpc_id         = module.vpc.vpc_id
  environment    = var.environment
  container_port = var.container_port
}

module "alb" {
  source              = "./modules/alb"
  name                = var.name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  alb_subnets_id      = module.vpc.public_subnets
  alb_security_groups = [module.security_groups.alb]
}


module "ecr_backend" {
  source      = "./modules/ecr"
  name        = var.name
  environment = var.environment
}
