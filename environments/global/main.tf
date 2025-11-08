terraform {
  backend "s3" {
    bucket = "pilot-light-dr-recovery-8325"
    key    = "global/terraform.tfstate"
    region = "us-east-1"
  }
}

variable "read_secondary_state" {
  description = "Set to true (1) only after the secondary region has been deployed."
  type        = bool
  default     = false
}

# Get secondary region ASG name from remote state (only after secondary is deployed)
data "terraform_remote_state" "secondary" {
  count = var.enable_automation && var.read_secondary_state ? 1 : 0

  backend = "s3"
  config = {
    bucket = "pilot-light-dr-recovery-8325"
    key    = "secondary/terraform.tfstate"
    region = "us-east-1"
  }
}

module "iam" {
  source = "../../modules/iam"
  project_name = var.project_name
  s3_replication_source_bucket_name = "pilot-light-dr-recovery-primary-app-data"
  s3_replication_destination_bucket_arn = "${var.project_name}-secondary-app-data"
  sns_topic_arn = var.sns_topic_arn
}

module "automation" {
  count  = var.enable_automation ? 1 : 0
  source = "../../modules/automation"

  project_name              = var.project_name
  secondary_region          = var.aws_secondary_region
  secondary_asg_name        = var.read_secondary_state ? data.terraform_remote_state.secondary[0].outputs.asg_name : ""
  failover_desired_capacity = 2

  # Use ALB alarm instead of Route 53 health check
  primary_alb_alarm_name = var.primary_alb_alarm_name

  sns_topic_arn   = var.sns_topic_arn
  enable_failback = false

  common_tags = var.common_tags
  lambda_failover_role_arn = module.iam.lambda_failover_role_arn
}



module "dynamodb" {
  source = "../../modules/dynamodb"

  project_name         = var.project_name
  environment          = "global"
  aws_secondary_region = var.aws_secondary_region
  common_tags          = var.common_tags
}

