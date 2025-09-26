output "launch_template_id" {
    description = "The ID of the launch template"
    value = aws_launch_template.main.id
}

output "launch_template_arn" {
    description = "The ARN of the launch template"
    value = aws_launch_template.main.arn
}

output "launch_template_name" {
    description = "The name of the launch template"
    value = aws_launch_template.main.name
}

output "launch_template_latest_version" {
    description = "The latest version of the launch template"
    value = aws_launch_template.main.latest_version
}

output "autoscaling_group_id" {
    description = "The ID of the Auto Scaling Group"
    value = aws_autoscaling_group.main.id
}

output "autoscaling_group_arn" {
    description = "The ARN of the Auto Scaling Group"
    value = aws_autoscaling_group.main.arn
}

output "autoscaling_group_name" {
    description = "The name of the Auto Scaling Group"
    value = aws_autoscaling_group.main.name
}

output "autoscaling_availability_zones" {
    description = "The availability zones of the Auto Scaling Group"
    value = aws_autoscaling_group.main.availability_zones
}

output "autoscaling_vpc_zone_identifier" {
    description = "The VPC zone identifiers of the Auto Scaling Group"
    value = aws_autoscaling_group.main.vpc_zone_identifier
}

output "autoscaling_min_size" {
    description = "The minimum size of the Auto Scaling Group"
    value = aws_autoscaling_group.main.min_size
}

output "autoscaling_max_size" {
    description = "The maximum size of the Auto Scaling Group"
    value = aws_autoscaling_group.main.max_size
}

output "autoscaling_desired_capacity" {
    description = "The desired capacity of the Auto Scaling Group"
    value = aws_autoscaling_group.main.desired_capacity
}

output "health_check_type" {
    description = "The health check type of the Auto Scaling Group"
    value = aws_autoscaling_group.main.health_check_type
}

output "health_check_grace_period" {
    description = "The health check grace period of the Auto Scaling Group"
    value = aws_autoscaling_group.main.health_check_grace_period
}

output "target_group_arns" {
    description = "The target group ARNs associated with the Auto Scaling Group"
    value = var.target_group_arns
}

output "security_groups_ids" {
    description = "The security groups associated with the Auto Scaling Group"
    value = var.security_group_ids
}

output "iam_instance_profile" {
    description = "The IAM instance profile associated with the Auto Scaling Group"
    value = var.iam_instance_profile
}

output "instance_type" {
    description = "The instance type of the launch template"
    value = var.instance_type
}

output "ami_id" {
    description = "The AMI ID of the launch template"
    value = var.ami_id
}

output "key_name" {
    description = "The key name used for the instances in the Auto Scaling Group"
    value = var.key_name
}

output "environment" {
    description = "The environment tag of the resources"
    value = var.environment
}

output "project_name" {
    description = "The project name tag of the resources"
    value = var.project_name
}

output "common_tags" {
    description = "The common tags applied to resources"
    value = var.common_tags
}

output "is_pilot_light" {
    description = "Indicates if the Auto Scaling Group is in pilot light mode"
    value = var.is_pilot_light
}

output "region" {
    description = "The AWS region where resources are deployed"
    value = var.aws_region
}

output "clouwatch_log_group_name" {
    description = "The name of the CloudWatch log group (if applicable)"
  value = ""
}

output "s3_bucket_name" {
  description = "S3 bucket name used by instances"
  value       = var.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name used by instances"
  value       = var.dynamodb_table_name
}

output "asg_resource_name" {
  description = "Full resource name for referencing in other modules"
  value       = "${var.environment}-${var.project_name}-asg"
}

output "launch_template_resource_name" {
  description = "Launch template resource name"
  value       = "${var.environment}-${var.project_name}-lt"
}