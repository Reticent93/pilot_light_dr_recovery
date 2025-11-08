output "failover_lambda_arn" {
  description = "ARN of the failover Lambda function"
  value       = aws_lambda_function.failover.arn
}

output "failover_lambda_name" {
  description = "Name of the failover Lambda function"
  value       = aws_lambda_function.failover.function_name
}

