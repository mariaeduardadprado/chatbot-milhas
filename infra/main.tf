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