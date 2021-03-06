# Instance type
variable "instance_type" {
  default = {
    #"prod"    = "t3.medium"
    #"test"    = "t3.micro"
    #"staging" = "t2.micro"
    "dev" = "t3.micro"
  }
  description = "Type of the instance"
  type        = map(string)
}

# Name prefix
variable "prefix" {
  type        = string
  default     = "Assignment2"
  description = "Name prefix"
}


# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}

variable "my_private_ip" {
  type        = string
  default     = "172.31.50.245"
  description = "Private IP of my Cloud 9 station to be opened in bastion ingress"
}

# curl http://169.254.169.254/latest/meta-data/public-ipv4
variable "my_public_ip" {
  type        = string
  default     = "34.207.188.73"
  description = "Public IP of my Cloud 9 station to be opened in bastion ingress"
}

variable "service_ports" {
  type        = list(string)
  default     = ["80", "22"]
  description = "Ports that should be open on a webserver"
}


