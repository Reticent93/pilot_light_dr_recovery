output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb.table_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb.table_name
}

output "s3_replication_role_arn" {
  description = "ARN of the S3 replication IAM role"
  value       = module.iam.s3_replication_role_arn
}

output "lambda_failover_role_arn" {
  description = "ARN of the Lambda failover IAM role for the primary stack."
  value       = module.iam.lambda_failover_role_arn
}

output "failover_lambda_arn" {
  description = "The ARN of the central DR Failover Orchestration Lambda function."
  value       = module.automation[0].failover_lambda_arn
}

output "failover_lambda_name" {
  description = "The name of the central DR Failover Orchestration Lambda function."
  value       = module.automation[0].failover_lambda_name
}

output "instance_profile_name" {
  description = "Name of the IAM Instance Profile for EC2 instances."
  value       = module.iam.instance_profile_name
}

output "instance_profile_arn" {
  description = "ARN of the IAM Instance Profile for EC2 instances."
  value       = module.iam.instance_profile_arn
}

