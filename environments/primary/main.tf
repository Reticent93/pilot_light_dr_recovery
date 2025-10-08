
module "vpc" {
    source = "../../modules/vpc"

    project_name         = var.project_name
    environment          = var.environment
    aws_primary_region   = var.aws_primary_region
    vpc_cidr            = var.vpc_configs.cidr_block
    public_subnet_cidrs = var.vpc_configs.public_subnet_cidrs
    private_subnet_cidrs = var.vpc_configs.private_subnet_cidrs
    availability_zones   = var.vpc_configs.availability_zones
}

module "security_groups" {
    source = "../../modules/security-groups"

    vpc_id              = module.vpc.vpc_id
    project_name        = var.project_name
    environment         = var.environment
}

module "load_balancer" {
    source = "../../modules/load-balancer"

    project_name = var.project_name
    name   = "${var.project_name}-${var.environment}-alb"
    subnet_ids = module.vpc.public_subnet_ids
    security_group_ids = [module.security_groups.alb_sg_id]
    vpc_id = module.vpc.vpc_id
}

module "asg" {
    source = "../../modules/asg"
    
    project_name         = var.project_name
    environment          = var.environment
    aws_region           = var.aws_primary_region
    instance_type        = var.asg_config.instance_type
    security_group_ids   = [module.security_groups.app_tier_sg_id]
    subnet_ids           = module.vpc.private_subnet_ids
    iam_instance_profile = ""
    min_size             = var.asg_config.min_size
    max_size             = var.asg_config.max_size
    desired_capacity     = var.asg_config.desired_capacity
    root_volume_size            = var.asg_config.root_volume_size
    additional_ebs_volume_size  = var.asg_config.additional_ebs_volume_size
    associate_public_ip  = var.asg_config.associate_public_ip_address
    detailed_monitoring  = var.asg_config.detailed_monitoring
    target_group_arns    = [module.load_balancer.target_group_arn]
    ami_id = ""
}