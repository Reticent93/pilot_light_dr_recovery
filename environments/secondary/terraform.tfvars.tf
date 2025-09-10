project_name = "pilot_light_dr_recovery"
aws_region = "eu-west-1"

vpc_configs = {
  main = {
    cidr_block           = "10.1.0.0/16"
    public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
    private_subnet_cidrs = ["10.1.10.0/24", "10.1.20.0/24"]
    availability_zones   = ["eu-west-1a", "eu-west-1b"]
    enable_dns_support   = true
    enable_dns_hostnames = true
  }
}