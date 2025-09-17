terraform {
  backend "s3" {
    bucket         = "your-state-bucket"
    key            = "terraform.tfstate"
    region         = "your-region"
    dynamodb_table = "${var.project_name}-table"  # Use your table name
  }
}