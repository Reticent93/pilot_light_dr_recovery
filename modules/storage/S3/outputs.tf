output "app_bucket_id" {
  description = "The ID of the app data bucket"
  value       = var.use_existing_buckets ? data.aws_s3_bucket.app_data_existing[0].id : aws_s3_bucket.app_data[0].id
}

output "app_bucket_arn" {
  description = "The ARN of the app data bucket"
  value       = var.use_existing_buckets ? data.aws_s3_bucket.app_data_existing[0].arn : aws_s3_bucket.app_data[0].arn
}

output "app_bucket_name" {
  description = "The name of the app data bucket"
  value       = var.use_existing_buckets ? data.aws_s3_bucket.app_data_existing[0].bucket : aws_s3_bucket.app_data[0].bucket
}

output "logs_bucket_id" {
  description = "The ID of the logs bucket"
  value       = var.use_existing_buckets ? data.aws_s3_bucket.logs_existing[0].id : aws_s3_bucket.logs[0].id
}

output "logs_bucket_arn" {
  description = "The ARN of the logs bucket"
  value       = var.use_existing_buckets ? data.aws_s3_bucket.logs_existing[0].arn : aws_s3_bucket.logs[0].arn
}

output "logs_bucket_name" {
  description = "The name of the logs bucket"
  value       = var.use_existing_buckets ? data.aws_s3_bucket.logs_existing[0].bucket : aws_s3_bucket.logs[0].bucket
}