terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "pilot-light-dr-recovery-8325"
    key            = "primary/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}

provider "aws" {
  region = var.aws_primary_region

  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias  = "secondary"
  region = var.aws_secondary_region

  default_tags {
    tags = var.common_tags
  }
}