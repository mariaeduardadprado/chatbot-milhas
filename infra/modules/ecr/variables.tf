variable "name" {
  description = "The name of your stack, e.g. \"demo\""
  type        = string
}

variable "environment" {
  description = "The name of your environment, e.g. \"prod\""
  default     = "sandbox"
  type        = string
}