variable "project_name" {
    description = "Name of the project"
    type        = string
}
variable "primary_region" {
    description = "Primary AWS region"
    type        = string
}

variable "primary_asg_name" {
    description = "Name of the primary region ASG"
    type        = string
}

variable "primary_tg_arn" {
    description = "ARN of the primary region target group"
    type        = string
    default     = "*"
}

variable "secondary_region" {
    description = "Secondary AWS region for failover"
    type        = string
    default = "eu-west-1"
}

variable "secondary_asg_name" {
    description = "Name of the secondary region ASG"
    type        = string
}

variable "failover_desired_capacity" {
    description = "Desired capacity to scale secondary ASG to during failover"
    type        = number
    default     = 2
}

variable "primary_eip_allocation_id" {
    description = "Allocation ID of the Elastic IP to disassociate during failover"
    type        = string
}

variable "secondary_eip_allocation_id" {
    description = "Allocation ID of the Elastic IP to associate during failover"
    type        = string

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

variable "common_tags" {
    description = "Common tags to apply to resources"
    type        = map(string)
    default     = {}
}
