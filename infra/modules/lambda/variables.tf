variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "ecs_endpoint" {
  description = "Endpoint do ALB/ECS"
  type        = string
}

variable "response_topic_arn" {
  description = "ARN do tópico SNS de resposta (fan-out)"
  type        = string
}

variable "user_messages_topic_arn" {
  description = "ARN do tópico SNS de entrada (fan-in)"
  type        = string
}
