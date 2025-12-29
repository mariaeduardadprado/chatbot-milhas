variable "name" {
  description = "The name of your stack, e.g. \"demo\""
  type        = string
}

variable "environment" {
  description = "The name of your environment, e.g. \"prod\""
  default     = "sandbox"
  type        = string
}

variable "region" {
  description = "The AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
  type        = string
}

variable "container_image" {
  description = "Docker image to be launched"
  type        = string
}

variable "container_port" {
  description = "The port where the Docker is exposed"
  type        = number
}

variable "container_cpu" {
  description = "The number of cpu units used by the task"
  default     = 256
  type        = number
}

variable "container_memory" {
  description = "The amount (in MiB) of memory used by the task"
  default     = 512
  type        = number
}

variable "service_desired_count" {
  description = "Number of tasks running in parallel"
  default     = 2
  type        = number
}

variable "ecs_subnets_id" {
  description = "The IDs of the ECS subnets where tasks will be launched"
  type        = list(string)
}

variable "aws_alb_target_group_arn" {
  description = "The ARN of the load balancer target group"
  type        = string
}

variable "ecs_service_security_groups" {
  description = "The ECS security group"
  type = list(string)
}
