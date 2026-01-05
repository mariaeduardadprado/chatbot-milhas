terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.name
      Environment = var.environment
    }
  }
}

# SNS Topics (Fan-in / Fan-out)
resource "aws_sns_topic" "user_messages_topic" {
  name = "${var.name}-user-messages-${var.environment}"
}

resource "aws_sns_topic" "response" {
  name = "${var.name}-response-${var.environment}"
}

# Lambda Module
module "lambda" {
  source = "./modules/lambda"

  name                    = var.name
  environment             = var.environment
  region                  = var.region

  # SNS
  user_messages_topic_arn = aws_sns_topic.user_messages_topic.arn
  response_topic_arn      = aws_sns_topic.response.arn

  # ECS / ALB
  ecs_endpoint = "chatbot-milhas-alb-dev-1144698258.us-east-1.elb.amazonaws.com"
}

# VPC
module "vpc" {
  source             = "./modules/vpc"
  name               = var.name
  environment        = var.environment
  cidr_block         = var.cidr_block
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
}

# Security Groups
module "security_groups" {
  source         = "./modules/security-groups"
  name           = var.name
  vpc_id         = module.vpc.vpc_id
  environment    = var.environment
  container_port = var.container_port
}

# ALB
module "alb" {
  source              = "./modules/alb"
  name                = var.name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  alb_subnets_id      = module.vpc.public_subnets
  alb_security_groups = [module.security_groups.alb]
}

# ECR
module "ecr_backend" {
  source      = "./modules/ecr"
  name        = var.name
  environment = var.environment
}

# ECS
module "ecs" {
  source                      = "./modules/ecs"
  name                        = var.name
  environment                 = var.environment
  region                      = var.region

  ecs_subnets_id              = module.vpc.private_subnets
  ecs_service_security_groups = [module.security_groups.ecs_tasks]

  aws_alb_target_group_arn    = module.alb.aws_alb_target_group_arn

  container_port              = var.container_port
  container_cpu               = var.container_cpu
  container_memory            = var.container_memory
  service_desired_count       = var.service_desired_count

  container_image             = module.ecr_backend.repository_url

  response_topic_arn          = aws_sns_topic.response.arn
}
