variable "project_name" {
    description = "Name of the project"
    type        = string
}

variable "aws_region" {
    description = "AWS region to deploy resources"
    type        = string
    default     = "us-east-1"
}

variable "vpc_configs" {
    description = "Configuration for VPC"
    type = object({
        cidr_block           = string
        public_subnet_cidrs  = list(string)
        private_subnet_cidrs = list(string)
        availability_zones   = list(string)
        enable_dns_support   = bool
        enable_dns_hostnames = bool
    })
}