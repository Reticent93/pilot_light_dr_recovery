variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}


variable "vpc_configs" {
  description = "Map of vpc config to add naming of VPC"
  type = object({
        vpc1 = object({
          cidr_block           = string
          public_subnet_cidrs  = list(string)
          private_subnet_cidrs = list(string)
          availability_zones  = list(string)
          enable_dns_support = bool
          enable_dns_hostnames = bool

        })
  })
}

