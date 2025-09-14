
resource "aws_vpc" "primary_vpc" {
        cidr_block = var.vpc_configs.cidr_block
        enable_dns_support = var.vpc_configs.enable_dns_support
        enable_dns_hostnames = var.vpc_configs.enable_dns_hostnames


    tags = {
        Name = var.project_name
    }
}

resource "aws_internet_gateway" "primary_igw" {
    vpc_id = aws_vpc.primary_vpc.id

    tags = {
        Name = "${var.project_name}-igw"
    }
}

resource "aws_route_table" "primary_public_rt" {
    vpc_id = aws_vpc.primary_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.primary_igw.id
    }
    tags = {
        Name = "${var.project_name}-public-rt"
    }
}

module "security_groups" {
    source = "../../modules/security-groups"
    vpc_id = aws_vpc.primary_vpc.id
    project_name = var.project_name
    environment = "primary"
    allowed_cidr_blocks = ["10.0.0.0/8", "203.0.113.0/24"]
}