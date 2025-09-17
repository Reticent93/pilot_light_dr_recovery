terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-${var.environment}"

  tags = {
    Name        = "${var.project_name}-s3-bucket"
    Environment = var.environment
    Region      = var.aws_primary_region
  }
}

resource "aws_s3_bucket" "replica" {
    provider = aws.secondary
    bucket   = "${var.project_name}-${var.environment}-replica"

    tags = {
      Name        = "${var.project_name}-s3-bucket-replica"
      Environment = var.environment
      Region      = var.aws_secondary_region
    }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "replica" {
    provider = aws.secondary
    bucket   = aws_s3_bucket.replica.id

    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_s3_bucket_replication_configuration" "main" {
  depends_on = [aws_s3_bucket_versioning.main, aws_s3_bucket_versioning.replica]
  bucket = aws_s3_bucket.main.id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "REPLICATION-TO-SECONDARY"
    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.replica.arn
        storage_class = "STANDARD-IA"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id = "transition-to-ia"
    status = "Enabled"


        transition {
            days          = 30
            storage_class = "STANDARD_IA"
        }

        expiration {
            days = 365
        }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

  }
}
