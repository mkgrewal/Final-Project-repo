# Default tags
variable "default_tags" {
  default = {
    "Owner" = "MKSR",
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# Name prefix
variable "prefix" {
  type        = string
  default     = "Assignment2"
  description = "Name prefix"
}

variable "availability_zones" {
  default     = ["us-east-1b", "us-east-1c", "us-east-1d"]
  type        = list(string)
  description = "availability zones"
}
# Provision public subnets in custom VPC
variable "public_subnet_cidrs" {
  default     = ["10.250.1.0/24", "10.250.2.0/24", "10.250.3.0/24"]
  type        = list(string)
  description = "Public Subnet CIDRs"
}

# Provision private subnets in custom VPC
variable "private_subnet_cidr" {
  default     = ["10.250.4.0/24", "10.250.5.0/24", "10.250.6.0/24"]
  type        = list(string)
  description = "Private Subnet CIDR"
}

# Provision private subnets in custom VPC
###variable "private_subnet_cidr_prod" {
###  default     = ["10.100.3.0/24", "10.100.4.0/24"]
###  type        = list(string)
##  description = "Private Subnet CIDR"
###}

# VPC CIDR range
variable "vpc_cidr" {
  default     = "10.250.0.0/16"
  type        = string
  description = "VPC to host static web site"
}

# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}



