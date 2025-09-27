# Load Balancer Module Variables
variable "name" {
  description = "The name of the load balancer"
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

variable "health_check_path" {
  description = "The health check path for the target group"
  type        = string
  default     = "/health"
}

variable "health_check_protocol" {
    description = "The health check protocol for the target group"
    type        = string
    default     = "HTTP"
}

variable "health_check_interval" {
    description = "The interval (in seconds) between health checks"
    type        = number
    default     = 30
}

variable "health_check_timeout" {
    description = "The timeout (in seconds) for each health check"
    type        = number
    default     = 5
}

variable "healthy_threshold" {
    description = "The number of consecutive successful health checks required to consider a target healthy"
    type        = number
    default     = 3
}

variable "unhealthy_threshold" {
    description = "The number of consecutive failed health checks required to consider a target unhealthy"
    type        = number
    default     = 3
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

variable "ssl_certificate_arn" {
    description = "The ARN of the SSL certificate (required if listener_protocol is HTTPS)"
    type        = string
    default     = ""
}

variable "enable_https" {
    description = "Whether to enable HTTPS listener"
    type        = bool
    default     = false
}

variable "https_port" {
    description = "The port for the HTTPS listener"
    type        = number
    default     = 443
}

variable "ssl_policy" {
    description = "The SSL policy for the HTTPS listener"
    type        = string
    default     = "ELBSecurityPolicy-2016-08"
}

# Disaster Recovery Specific Settings
variable "is_pilot_light" {
    description = "Whether this load balancer is part of a pilot light setup"
    type        = bool
    default     = false
}

variable "enable_cross_zone_load_balancing" {
    description = "Whether to enable cross-zone load balancing"
    type        = bool
    default     = true
}

variable "idle_timeout" {
    description = "The idle timeout (in seconds) for the load balancer"
    type        = number
    default     = 60
}

variable "enable_http2" {
    description = "Whether to enable HTTP/2 for the load balancer (only applicable for application load balancers)"
    type        = bool
    default     = true
}

# Access Logs Configuration
variable "access_logs_enabled" {
    description = "Whether to enable access logs for the load balancer"
    type        = bool
    default     = true
}

variable "access_logs_bucket" {
  description = "The S3 bucket to store access logs (required if access_logs_enabled is true)"
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "The prefix for the access logs in the S3 bucket"
  type        = string
  default     = "load-balancer-logs/"
}

# Route 53 Configuration
variable "domain_name" {
    description = "The domain name for the load balancer (for Route 53 record)"
    type        = string
    default     = ""
}

variable "route53_zone_id" {
  description = "The Route 53 zone ID for DNS records"
  type        = string
  default     = ""
}

variable "route53_enabled" {
  description = "Whether to enable Route 53 integration"
  type        = bool
  default     = false
}

# ASG Integration
variable "asg_target_group_arn" {
  description = "ASG ARN to attach to an Auto Scaling Group"
  type        = string
  default     = ""
}

# Monitoring and Alarms
variable "enable_cloudwatch_alarms" {
  description = "Whether to enable CloudWatch alarms for the load balancer"
  type        = bool
  default     = true
}

variable "alarm_actions" {
    description = "List of ARNs to notify when an alarm is triggered"
    type        = list(string)
    default     = []
}

variable "ok_actions" {
    description = "List of ARNs to notify when an alarm goes to OK state"
    type        = list(string)
    default     = []
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the load balancer"
  type        = map(string)
  default     = {}
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

