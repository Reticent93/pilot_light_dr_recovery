variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "aws_primary_region" {
  description = "AWS region"
  type        = string

}

variable "aws_secondary_region" {
  description = "AWS region"
  type        = string

}

variable "environment" {
  description = "Environment name"
  type        = string
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

# S3 bucket configuration
variable "s3_config" {
  description = "Configuration for S3 bucket"
  type = object({
    s3_bucket_name = string
    s3_bucket_arn  = string
  })
}

variable "asg_config" {
  description = "Configuration for ASG"
  type = object({
    instance_type               = string
    desired_capacity            = number
    max_size                    = number
    min_size                    = number
    root_volume_size            = number
    additional_ebs_volume_size  = number
    associate_public_ip_address = bool
    detailed_monitoring         = bool
  })
}

variable "alb_config" {
  description = "Configuration for ALB"
  type = object({
    name                       = string
    internal                   = bool
    load_balancer_type         = string
    enable_deletion_protection = bool
    target_group_port          = number
    listener_port              = number
    health_check_path          = string
    enable_cloudwatch_alarms   = bool
    access_logs_bucket_name    = string
  })
}

variable "monitoring_config" {
  description = "Configuration for monitoring and logging"
  type = object({
    enable_cloudwatch_alarms       = bool
    unhealthy_host_count_threshold = number
    response_time_threshold        = number
    enable_access_logs             = bool
  })
}


variable "common_tags" {
  description = "Tags for resources"
  type        = map(string)
}

