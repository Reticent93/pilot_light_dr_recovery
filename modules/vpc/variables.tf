variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "aws_primary_region" {
    description = "Primary AWS Region"
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

variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type        = string
}

variable "availability_zones" {
    description = "List of availability zones"
    type        = list(string)
}

variable "environment" {
    description = "Deployment environment (e.g., dev, staging, prod)"
    type        = string
}