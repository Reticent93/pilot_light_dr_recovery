bucket         = "pilot-dr-state-primary"
key            = "primary/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-state-locks"