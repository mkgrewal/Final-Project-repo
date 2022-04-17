# Default tags
variable "default_tags" {
  default     = {}
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# Name prefix
variable "prefix" {
  type        = string
  description = "Name prefix"
}

# Provision public subnets in custom VPC
variable "public_cidr_blocks" {
  type        = list(string)
  description = "Public Subnet CIDRs"
}

# Provision public subnets in custom VPC
variable "private_cidr_blocks" {
  type        = list(string)
  description = "Private Subnet CIDRs"
}

variable "availability_zones" {
  default     = ["us-east-1b", "us-east-1c", "us-east-1d"]
  type        = list(string)
  description = "availability zones"
}

# VPC CIDR range
variable "vpc_cidr" {
  type        = string
  description = "VPC to host static web site"
}

# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}

# Provision private subnets in custom VPC
#variable "private_subnet_cidr_prod" {
#  default     = ["10.100.3.0/24", "10.100.4.0/24"]
# type        = list(string)
#description = "Private Subnet CIDR"
#}