variable "vpc_id" {
    description = "The ID of the VPC where security groups will be created"
    type        = string
}

variable "project_name" {
    description = "Name of the project"
    type        = string
}

variable "environment" {
    description = "Name of the environment"
    type        = string
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed for SSH access"
    type        = list(string)
  default     = ["10.0.0.0/8"]
}