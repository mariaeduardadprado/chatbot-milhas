variable "name" {
  description = "Name for the VPC"
  type        = string
}

variable "environment" {
  description = "The name of your environment, e.g. \"prod\""
  default     = "sandbox"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
} 

variable "private_subnets" {
  description = "A list of CIDRs for private subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = ["10.0.0.0/20", "10.0.32.0/20", "10.0.64.0/20"]
  type        = list(string)
}

variable "public_subnets" {
  description = "A list of CIDRs for public subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = ["10.0.16.0/20", "10.0.48.0/20", "10.0.80.0/20"]
  type        = list(string)
}

variable "availability_zones" {
  description = "A comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both private_subnets and public_subnets have to be defined as well"
  type        = list(string)
}