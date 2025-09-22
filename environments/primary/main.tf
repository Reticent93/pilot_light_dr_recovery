
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
    allowed_cidr_blocks = ["10.0.0.0/8", "203.0.113.0/24"]
}