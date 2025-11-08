variable "project_name" {
    description = "Name of the project"
    type        = string
}

variable "secondary_region" {
    description = "Secondary AWS region for failover"
    type        = string
}

variable "secondary_asg_name" {
    description = "Name of the secondary region ASG"
    type        = string
}

variable "secondary_asg_arn" {
    description = "ARN of the secondary region ASG"
    type        = string
    default     = "*"
}

variable "failover_desired_capacity" {
    description = "Desired capacity to scale secondary ASG to during failover"
    type        = number
    default     = 2
}

variable "primary_alb_alarm_name" {
    description = "Name of the CloudWatch alarm that triggers failover (ALB unhealthy hosts)"
    type        = string
}

variable "sns_topic_arn" {
    description = "SNS topic ARN for notifications"
    type        = string

}

variable "lambda_failover_role_arn" {
    description = "The ARN of the IAM role for the Lambda failover function."
    type        = string
}

variable "enable_failback" {
    description = "Enable automatic failback when primary recovers"
    type        = bool
    default     = false
}

variable "common_tags" {
    description = "Common tags to apply to resources"
    type        = map(string)
    default     = {}
}
