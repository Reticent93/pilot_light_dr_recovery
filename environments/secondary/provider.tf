terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }


  backend "s3" {
    bucket         = "pilot-light-dr-recovery-8325"
    key            = "secondary/terraform.tfstate" # This is the key the Global module is looking for
    region         = "us-east-1"                   # This MUST be the region where the S3 bucket is located
    encrypt        = true
    dynamodb_table = "terraform-state-locks" # Use the same lock table as Primary for consistency
  }
}

provider "aws" {
  region = "eu-west-1"
}
