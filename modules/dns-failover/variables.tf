variable "project_name" {
    description = "Name of the project"
    type        = string
}

variable "aws_region" {
    description = "AWS region to deploy resources"
    type        = string
}

variable "primary_alb_dns_name" {
    description = "DNS name of the primary ALB to monitor"
    type        = string
}

variable "primary_alb_zone_id" {
    description = "Route 53 zone ID for the primary ALB"
    type        = string
}

variable "health_check_path" {
    description = "Path for the health check"
    type        = string
    default     = "/health"
}

variable "secondary_alb_dns_name" {
    description = "DNS name of the secondary ALB"
    type        = string
}

variable "secondary_alb_zone_id" {
    description = "Route 53 zone ID for the secondary ALB"
    type        = string
}

variable "hosted_zone_id" {
    description = "Route 53 Hosted Zone ID"
    type        = string
}

variable "domain_name" {
    description = "Domain name for the DNS record"
    type        = string
}

variable "sns_topics_arn" {
    description = "List of SNS topic ARNs for alarm notifications"
    type        = list(string)
    default     = []
}

variable "common_tags" {
    description = "Common tags to apply to resources"
    type        = map(string)
    default     = {}
}