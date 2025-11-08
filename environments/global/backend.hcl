    bucket             = "pilot-light-dr-recovery-8325"
    key                = "global/terraform.tfstate"
    region             = "us-east-1"
    encrypt            = true
    dynamodb_table     = "terraform-state-locks"
