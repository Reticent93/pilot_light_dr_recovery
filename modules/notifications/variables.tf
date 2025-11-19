variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "email_endpoints" {
  description = "List of email addresses for notifications"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "failover_lambda_arn" {
  description = "The ARN of the Lambda function created in the automation module that needs to be subscribed to the primary alerts topic."
  type        = string
}

variable "failover_lambda_name" {
    description = "The name of the Lambda function created in the automation module that needs to be subscribed to the primary alerts topic."
    type        = string
}

