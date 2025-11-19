terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Primary region provider (us-east-1)
provider "aws" {
    alias  = "primary"
  region = var.aws_primary_region
  default_tags {
    tags = var.common_tags
  }
}

# Secondary region provider (eu-west-1) - for creating replica bucket
provider "aws" {
  alias  = "secondary"
  region = var.aws_secondary_region

  default_tags {
    tags = var.common_tags
  }
}