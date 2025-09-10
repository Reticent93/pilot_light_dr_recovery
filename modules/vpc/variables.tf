variable "project_name" {
  description = "Name of the project"
  type        = string
}


variable "public_subnet_cidrs" {
    description = "List of public subnet CIDR blocks"
    type        = list(string)
}

variable "private_subnet_cidrs" {
    description = "List of private subnet CIDR blocks"
    type        = list(string)
}

variable "igw_id" {
    description = "ID of the Internet Gateway"
    type        = string
}

variable "ngw_id" {
    description = "ID of the NAT Gateway"
    type        = string
}

variable "vpc_id" {
    description = "The ID of the VPC"
    type        = string
}

variable "public_route_table_id" {
  description = "ID of the public route table"
  type        = string
}

variable "private_route_table_id" {
  description = "ID of the private route table"
  type        = string
}

variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type        = string
}