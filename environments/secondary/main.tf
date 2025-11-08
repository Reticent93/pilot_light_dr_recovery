# Get global resources (DynamoDB, S3 replication role)
data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    bucket = "pilot-light-dr-recovery-8325"
    key    = "global/terraform.tfstate"
    region = "us-east-1"
  }
}


module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  aws_primary_region   = var.aws_secondary_region # Using secondary as the active region
  vpc_cidr             = var.vpc_configs.cidr_block
  public_subnet_cidrs  = var.vpc_configs.public_subnet_cidrs
  private_subnet_cidrs = var.vpc_configs.private_subnet_cidrs
  availability_zones   = var.vpc_configs.availability_zones
}

# Reference existing buckets in secondary region
data "aws_s3_bucket" "app_data" {
  bucket = "pilot-light-dr-recovery-secondary-app-data"
}

data "aws_s3_bucket" "logs" {
  bucket = "pilot-light-dr-recovery-logs"
}

data "aws_dynamodb_table" "main" {
  name = "pilot-light-dr-recovery-table"
}

data "aws_iam_role" "ec2_role" {
  name = "pilot-light-dr-recovery-ec2-role"

}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "pilot-light-dr-recovery-ec2-instance-profile"
  role = data.aws_iam_role.ec2_role.name
}

# Create DR-specific folder structure in secondary logs bucket
resource "aws_s3_object" "dr_folders" {
  for_each = toset([
    "secondary-region/dr-snapshots/",
    "secondary-region/failover-data/",
    "secondary-region/recovery-scripts/",
    "secondary-region/config-backups/",
    "secondary-region/database-dumps/",
    "secondary-region/logs/",
    "secondary-region/temp/"
  ])

  bucket        = data.aws_s3_bucket.logs.id
  key           = each.value
  content       = ""
  content_type  = "application/x-directory"

  tags = {
    Purpose   = "disaster-recovery"
    DRRegion  = "secondary"
    ManagedBy = "terraform"
  }
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
  access_logs_bucket_name = data.aws_s3_bucket.logs.id
  tags                    = var.common_tags


}

module "asg" {
  source = "../../modules/asg"

  project_name               = var.project_name
  environment                = var.environment
  aws_region                 = var.aws_secondary_region
  instance_type              = var.asg_config.instance_type
  security_group_ids         = [module.security_groups.app_tier_sg_id]
  subnet_ids                 = module.vpc.private_subnet_ids
  iam_instance_profile       = aws_iam_instance_profile.ec2_instance_profile.name
  min_size                   = 0 # Pilot light - start with 0
  max_size                   = var.asg_config.max_size
  desired_capacity           = 0 # Pilot light - start with 0
  root_volume_size           = var.asg_config.root_volume_size
  additional_ebs_volume_size = var.asg_config.additional_ebs_volume_size
  associate_public_ip        = var.asg_config.associate_public_ip_address
  detailed_monitoring        = var.asg_config.detailed_monitoring
  target_group_arns          = [module.load_balancer.target_group_arn]
  ami_id                     = ""
}

