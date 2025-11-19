variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (primary or secondary)"
  type        = string
}

variable "use_existing_buckets" {
  description = "Whether to use existing buckets (true) or create new ones (false)"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Enable versioning for S3 buckets"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable encryption for S3 buckets"
  type        = bool
  default     = true
}

variable "enable_replication" {
  description = "Enable cross-region replication"
  type        = bool
  default     = false
}

variable "replication_role_arn" {
  description = "ARN of the IAM role for replication"
  type        = string
  default     = ""
}

variable "replication_destination_bucket_arn" {
  description = "ARN of the destination bucket for replication"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "existing_app_data_bucket" {
  description = "Name of the existing app-data bucket to use."
  type        = string
  default     = ""
}

variable "existing_logs_bucket" {
  description = "Name of the existing logs bucket to use."
  type        = string
  default     = ""
}
