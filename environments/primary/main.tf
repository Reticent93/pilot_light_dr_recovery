# Get global resources (DynamoDB, S3 replication role)
data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    bucket = "pilot-light-dr-recovery-8325"
    key    = "global/terraform.tfstate"
    region = "us-east-1"
  }
}

# Create secondary region app-data bucket (for replication destination)
resource "aws_s3_bucket" "secondary_app_data" {
  provider = aws.secondary
  bucket   = "${var.project_name}-secondary-app-data"

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-secondary-app-data"
      Purpose     = "application-data-replica"
      Environment = "secondary"
    }
  )
}

resource "aws_s3_bucket_versioning" "secondary_app_data" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.secondary_app_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secondary_app_data" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.secondary_app_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Create primary region storage
module "storage" {
  source = "../../modules/storage/s3"

  project_name = var.project_name
  environment  = var.environment

  enable_versioning                  = true
  enable_encryption                  = true
  enable_replication                 = true
  use_existing_app_data_bucket       = true
  existing_app_data_bucket           = "pilot-light-dr-recovery-primary-app-data"
  existing_logs_bucket               = ""
  replication_role_arn               = data.terraform_remote_state.global.outputs.s3_replication_role_arn
  replication_destination_bucket_arn = aws_s3_bucket.secondary_app_data.arn

  common_tags = var.common_tags

}


module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  aws_primary_region   = var.aws_primary_region
  vpc_cidr             = var.vpc_configs.cidr_block
  public_subnet_cidrs  = var.vpc_configs.public_subnet_cidrs
  private_subnet_cidrs = var.vpc_configs.private_subnet_cidrs
  availability_zones   = var.vpc_configs.availability_zones
}

module "iam" {
  source = "../../modules/iam"

  project_name       = var.project_name
  s3_bucket_arn      = module.storage.app_bucket_arn
  dynamodb_table_arn = data.terraform_remote_state.global.outputs.dynamodb_table_arn
  common_tags        = var.common_tags
  s3_replication_source_bucket_name = "pilot-light-dr-recovery-primary-app-data"
  s3_replication_destination_bucket_arn = "${var.project_name}-secondary-app-data"
  sns_topic_arn = module.notifications.topic_arn
}

module "security_groups" {
  source = "../../modules/security-groups"

  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  environment  = var.environment
}

module "load_balancer" {
  source = "../../modules/load-balancer"

  project_name            = var.project_name
  name                    = "${var.project_name}-${var.environment}-alb"
  subnet_ids              = module.vpc.public_subnet_ids
  security_group_ids      = [module.security_groups.alb_sg_id]
  enable_access_logs      = true
  vpc_id                  = module.vpc.vpc_id
  access_logs_bucket_name = module.storage.logs_bucket_id
  tags                    = var.common_tags
 target_group_port = var.alb_config.target_group_port

  depends_on = [module.storage]
}

module "asg" {
  source = "../../modules/asg"

  project_name               = var.project_name
  environment                = var.environment
  aws_region                 = var.aws_primary_region
  instance_type              = var.asg_config.instance_type
  security_group_ids         = [module.security_groups.app_tier_sg_id]
  subnet_ids                 = module.vpc.private_subnet_ids
  iam_instance_profile       = module.iam.instance_profile_name
  min_size                   = var.asg_config.min_size
  max_size                   = var.asg_config.max_size
  desired_capacity           = var.asg_config.desired_capacity
  root_volume_size           = var.asg_config.root_volume_size
  additional_ebs_volume_size = var.asg_config.additional_ebs_volume_size
  associate_public_ip        = var.asg_config.associate_public_ip_address
  detailed_monitoring        = var.asg_config.detailed_monitoring
  target_group_arns          = [module.load_balancer.target_group_arn]
  ami_id                     = ""
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name        = var.project_name
  environment         = "primary"
  aws_region          = var.aws_primary_region
  alb_arn_suffix      = module.load_balancer.alb_arn_suffix
  asg_name            = module.asg.asg_name
  dynamodb_table_name = data.terraform_remote_state.global.outputs.dynamodb_table_name
  sns_topic_arns      = [module.notifications.topic_arn]
  lambda_failover_arn = data.terraform_remote_state.global.outputs.failover_lambda_arn
  common_tags = var.common_tags

}

module "notifications" {
  source = "../../modules/notifications"

  project_name    = var.project_name
  environment     = "primary"
  email_endpoints = ["greg.renfro93@gmail.com"]
  failover_lambda_arn = data.terraform_remote_state.global.outputs.failover_lambda_arn
  failover_lambda_name = data.terraform_remote_state.global.outputs.failover_lambda_name
  sns_topic_arn = ""

  common_tags = var.common_tags
}

resource "aws_lambda_permission" "allow_sns_invocation" {
  statement_id  = "AllowExecutionFromSNSTopic"
  action        = "lambda:InvokeFunction"
  # The Lambda to be invoked
  function_name = data.terraform_remote_state.global.outputs.failover_lambda_name
  # The service principal for SNS
  principal     = "sns.amazonaws.com"
  # The ARN of the SNS Topic (created by the notifications module)
  source_arn    = module.notifications.topic_arn
}