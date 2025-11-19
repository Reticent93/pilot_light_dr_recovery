variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
  default     = ""
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic the Lambda function is allowed to publish to."
  type        = string
}
