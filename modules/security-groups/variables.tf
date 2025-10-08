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

variable "tags" {
    description = "A map of tags to assign to resources"
    type        = map(string)
    default     = {}
}