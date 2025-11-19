variable "environment" {
  description = "Environment name (e.g., dev, prod)"
    type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Name of the application"
  type        = string
  default = "pilot-light-dr-recovery"
}

# Launch template variables
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the launch template"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "Security group IDs for EC2 instances"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM instance profile for EC2 instances"
  type        = string
}

variable "associate_public_ip" {
    description = "Whether to associate a public IP address"
    type        = bool
    default     = false
}

variable "detailed_monitoring" {
    description = "Whether to enable detailed monitoring"
    type        = bool
    default     = false
}


#Storage config
variable "root_volume_size" {
    description = "Root volume size in GB"
    type        = number
    default     = 30
}

variable "enable_additional_volume" {
    description = "Whether to enable an additional EBS volume for logs and temp data"
    type        = bool
    default     = true
}

variable "additional_ebs_volume_size" {
    description = "Size of the additional EBS volume in GB"
    type        = number
    default     = 20
}

variable "kms_key_id" {
    description = "KMS Key ID for EBS volume encryption (if not provided, default AWS EBS KMS key will be used)"
    type        = string
    default     = ""
}

# Auto Scaling Group variables
variable "min_size" {
    description = "Minimum size of the Auto Scaling group"
    type        = number
    default     = 2
}

variable "max_size" {
    description = "Maximum size of the Auto Scaling group"
    type        = number
    default     = 3
}

variable "desired_capacity" {
    description = "Desired capacity of the Auto Scaling group"
    type        = number
    default     = 3
}

variable "subnet_ids" {
    description = "Subnet IDs for the Auto Scaling group"
    type        = list(string)
}

variable "target_group_arns" {
    description = "List of target group ARNs to attach to ASG"
    type        = list(string)
    default     = []
}

# Health check config
variable "health_check_type" {
    description = "Health check type for ASG (EC2 or ELB)"
    type        = string
    default     = "ELB"
}

variable "health_check_grace_period" {
    description = "Health check grace period in seconds"
    type        = number
    default     = 300
}

variable "min_healthy_percentage" {
    description = "Minimum healthy percentage during instance refresh"
    type        = number
    default     = 50
}

variable "instance_warmup" {
    description = "Instance warmup during instance refresh"
    type        = number
    default     = 300
}

# Termination and lifecycle policies
variable "termination_policies" {
    description = "Termination policies for the Auto Scaling group"
    type        = list(string)
    default     = ["OldestInstance", "OldestLaunchTemplate"]
}

variable "protect_from_scale_in" {
    description = "Whether to protect instances from scale-in"
    type        = bool
    default     = false
}

variable "enable_lifecycle_hooks" {
    description = "Whether to enable lifecycle hooks"
    type        = bool
    default     = false
}

variable "sns_topic_arn" {
    description = "SNS topic ARN for lifecycle hook notifications"
    type        = string
    default     = ""
}

variable "lifecycle_hook_role_arn" {
    description = "IAM role ARN for lifecycle hooks"
    type        = string
    default     = ""
}

# Scaling config
variable "enable_target_tracking_scaling" {
    description = "Whether to enable target tracking scaling policy"
    type        = bool
    default     = false
}

variable "target_cpu_utilization" {
    description = "Target CPU utilization for target tracking scaling policy"
    type        = number
    default     = 80
}

variable "target_request_count_per_target" {
    description = "Target request count per target for target tracking scaling policy"
    type        = number
    default     = 1000
}
variable "enable_step_scaling" {
    description = "Whether to enable step scaling policies"
    type        = bool
    default     = false
}

variable "scale_out_cooldown" {
    description = "Cooldown period in seconds after a scale-out activity"
    type        = number
    default     = 300
}

# Application config
variable "s3_bucket_name" {
    description = "S3 bucket name for application data"
    type        = string
    default     = ""
}

variable "dynamodb_table_name" {
    description = "DynamoDB table name for application data"
    type        = string
    default     = ""
}

variable "dynamodb_region" {
    description = "AWS region for DynamoDB table (for Global Tables)"
    type        = string
    default     = ""
}

# CloudWatch config
variable "enable_cloudwatch_alarms" {
    description = "Whether to enable CloudWatch alarms for ASG"
    type        = bool
    default     = true
}

variable "alarm_actions" {
    description = "List of ARNs for alarm actions (SNS topics)"
    type        = list(string)
    default     = []
}

variable "ok_actions" {
    description = "List of ARNs for OK actions (SNS topics)"
    type        = list(string)
    default     = []
}

# Environment config
variable "is_pilot_light" {
    description = "Whether this ASG is part of a pilot light DR setup"
    type        = bool
    default     = false
}

variable "pilot_light_instance_type" {
    description = "Instance type for pilot light instances (smaller size)"
    type        = string
    default     = "t3.micro"
}

variable "pilot_light_min_capacity" {
    description = "Minimum capacity for pilot light environment"
    type        = number
    default     = 1
}

variable "pilot_light_max_capacity" {
    description = "Maximum capacity for pilot light environment"
    type        = number
    default     = 1
}

variable "pilot_light_desired_capacity" {
    description = "Desired capacity for pilot light environment"
    type        = number
    default     = 1
}

variable "common_tags" {
    description = "Common tags for all resources"
    type        = map(string)
    default     = {}
}

variable "eip_allocation_id" {
    description = "The Allocation ID of the static EIP to be associated by the instance user data."
    type        = string
}