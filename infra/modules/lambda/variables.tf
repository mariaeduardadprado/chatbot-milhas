variable "name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}

variable "region" {
  description = "Região AWS"
  type        = string
}