variable "project_name" {
    description = "Name of the project"
    type        = string
}

variable "dr_region" {
    description = "AWS region"
    type        = string
}

variable "environment" {
    description = "Deployment environment (primary/secondary)"
    type        = string
    default     = "dev"
}