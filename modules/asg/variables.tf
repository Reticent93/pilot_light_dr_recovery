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

variable "additional_ebs_volume_size" {
    description = "Size of the additional EBS volume in GB"
    type        = number
    default     = 20
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

variable "common_tags" {
    description = "Common tags for all resources"
    type        = map(string)
    default     = {}
}

variable "eip_allocation_id" {
    description = "The Allocation ID of the static EIP to be associated by the instance user data."
    type        = string
}