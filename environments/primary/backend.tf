terraform {
  backend "s3" {
    bucket = "pilot-dr-recovery-primary"
    key = "pilot-light-dr/primary/terraform.tfstate"
    region = var.aws_region
    encrypt = true
    dynamodb_table = "terraform-state-locks"
  }
}