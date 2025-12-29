variable "name" {
  description = "The name of your stack, e.g. \"demo\""
  type        = string
}

variable "environment" {
  description = "The name of your environment, e.g. \"prod\""
  default     = "sandbox"
  type        = string
}

variable "alb_subnets_id" {
  description = "The IDs of the Application Load Balancer subnets where tasks will be launched"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be created"
  type        = string
}

variable "alb_security_groups" {
  description = "The Application Load Balancer security group"
  type = list(string)
}
