# Load Balancer Module Variables
variable "name" {
  description = "The name of the load balancer"
  type        = string
}

variable "project_name" {
    description = "Name of the project"
    type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to attach to the load balancer"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the load balancer"
  type        = list(string)
  default     = []
}

variable "load_balancer_type" {
  description = "The type of load balancer (application or network)"
  type        = string
  default     = "application"
}

variable "internal" {
  description = "Whether the load balancer is internal"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = false
}

# Target Group Configuration
variable "target_group_port" {
    description = "The port for the target group"
    type        = number
    default     = 80
}

variable "target_group_protocol" {
    description = "The protocol for the target group (HTTP, HTTPS, TCP, etc.)"
    type        = string
    default     = "HTTP"
}

variable "health_check_enabled" {
    description = "Whether to enable health checks for the target group"
    type        = bool
    default     = true
}

variable "healthy_threshold" {
  description = "The number of consecutive health check successes required before considering an unhealthy target healthy"
  type        = number
  default     = 3
}

variable "unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering a target unhealthy"
  type        = number
  default     = 3
}

variable "health_check_path" {
  description = "The health check path for the target group"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "The approximate amount of time, in seconds, between health checks of an individual target"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "The amount of time, in seconds, during which no response means a failed health check"
  type        = number
  default     = 5
}

variable "health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful response from a target"
  type        = string
  default     = "200"
}

# Listener Configuration
variable "listener_port" {
    description = "The port for the load balancer listener"
    type        = number
    default     = 80
}

variable "listener_protocol" {
  description = "The protocol for the load balancer listener (HTTP, HTTPS, TCP, etc.)"
  type        = string
  default     = "HTTP"
}


variable "access_logs_bucket" {
  description = "The S3 bucket to store access logs (required if access_logs_enabled is true)"
  type        = string
  default     = ""
}

# Monitoring and Alarms
variable "enable_cloudwatch_alarms" {
  description = "Whether to enable CloudWatch alarms for the load balancer"
  type        = bool
  default     = true
}

variable "enable_access_logs" {
    description = "Whether to enable access logs for the load balancer"
    type        = bool
    default     = true
}

variable "sns_topic_arn" {
    description = "SNS topic ARN for CloudWatch alarms"
    type        = string
    default     = ""
}

variable "unhealthy_host_count_threshold" {
    description = "Threshold for unhealthy host count to trigger an alarm"
    type        = number
    default     = 1
}

variable "api_target_group_port" {
    description = "The port for the API target group"
    type        = number
    default     = 80
}

variable "enable_api_routing" {
    description = "Whether to enable API routing"
    type        = bool
    default     = false
}

variable "api_path_patterns" {
    description = "List of path patterns for API routing"
    type        = list(string)
    default     = ["/api/*"]
}

variable "api_rule_priority" {
    description = "Priority for the API listener rule"
    type        = number
    default     = 100
}

variable "api_health_check_path" {
    description = "The health check path for the API target group"
    type        = string
    default     = "/api/health"
}

variable "enable_https" {
    description = "Whether to enable HTTPS listener with SSL certificate"
    type        = bool
    default     = false
}

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener (required if enable_https is true)"
  type        = string
  default     = ""
}

variable "ssl_policy" {
    description = "The SSL policy for the HTTPS listener"
    type        = string
    default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the load balancer"
  type        = map(string)
  default     = {}
}

