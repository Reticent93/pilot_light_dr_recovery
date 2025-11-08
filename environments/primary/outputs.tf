output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.asg.asg_name
}

output "asg_arn" {
  description = "Auto Scaling Group ARN"
  value       = module.asg.asg_arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.load_balancer.alb_dns_name
}

output "app_data_bucket_name" {
  description = "Name of the primary app data bucket"
  value       = module.storage.app_bucket_name
}

output "logs_bucket_name" {
  description = "Name of the logs bucket"
  value       = module.storage.logs_bucket_name
}

output "secondary_app_data_bucket_name" {
  description = "Name of the secondary app data replica bucket"
  value       = aws_s3_bucket.secondary_app_data.bucket
}