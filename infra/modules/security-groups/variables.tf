variable "name" {
  description = "The name of your stack, e.g. \"demo\""
  type        = string
}

variable "environment" {
  description = "The name of your environment, e.g. \"prod\""
  default     = "sandbox"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be created"
  type        = string
}

variable "container_port" {
  description = "The port where the Docker is exposed"
  type        = string
}