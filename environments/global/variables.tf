# environments/global/variables.tf

variable "project_name" {
    description = "Name of the project"
    type        = string
}

variable "domain_name" {
    description = "Domain name for the application"
    type        = string
}


variable "primary_alb_dns_name" {
    description = "DNS name of primary region ALB"
    type        = string
}

variable "primary_alb_zone_id" {
    description = "Zone ID of primary region ALB"
    type        = string
}

variable "secondary_alb_dns_name" {
    description = "DNS name of secondary region ALB"
    type        = string
}

variable "secondary_alb_zone_id" {
    description = "Zone ID of secondary region ALB"
    type        = string
}
