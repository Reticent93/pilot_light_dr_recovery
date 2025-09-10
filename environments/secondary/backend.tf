terraform {
  backend "s3" {
    bucket = "pilot-dr-recovery-secondary"
    key = "pilot-light-dr/primary/terraform.tfstate"
    region = "eu-west-1"
    encrypt = true
    dynamodb_table = "terraform-state-locks"
  }
}