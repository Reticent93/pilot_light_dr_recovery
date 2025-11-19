variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "pilot-light-dr-recovery"
}

variable "aws_primary_region" {
  description = "AWS region for global resources"
  type        = string
}

variable "secondary_eip_allocation_id" {
  description = "Allocation ID of the Elastic IP used for traffic failover."
  type        = string
}

variable "aws_secondary_region" {
  description = "AWS secondary region"
  type        = string
  default     = "eu-west-1"
}

variable "enable_automation" {
  description = "Enable automation module (set to true after secondary region is deployed)"
  type        = bool
  default     = false
}

variable "secondary_asg_name" {
  description = "Name of the secondary region ASG"
  type        = string
  default     = "" # Will be populated after secondary region is deployed
}

variable "sns_topic_arn" {
  description = "ARN of SNS topic for notifications"
  type        = string
  default     = ""
}

variable "aws_eip" {
  description = "Allocate and associate an Elastic IP address"
  type        = bool
  default     = true
}

variable "primary_asg_name" {
    description = "Name of the primary region ASG"
    type        = string
    default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "pilot-light-dr-recovery"
    ManagedBy   = "terraform"
    Environment = "global"
  }
}

variable "failover_lambda_arn" {
    description = "ARN of the failover Lambda function"
    type        = string
    default     = ""
}

variable "primary_alb_alarm_name" {
    description = "Name of the primary ALB CloudWatch alarm"
    type        = string

}

variable "primary_tg_arn" {
  description = "ARN of the primary region target group."
  type        = string
}
