
# --- APP DATA BUCKET ---
data "aws_s3_bucket" "app_data_existing" {
  count  = var.use_existing_buckets ? 1 : 0
  bucket = var.existing_app_data_bucket
}

resource "aws_s3_bucket" "app_data" {
  count  = var.use_existing_buckets ? 0 : 1
  bucket = "${var.project_name}-${var.environment}-app-data"

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-app-data"
      Purpose     = "application-data"
      Environment = var.environment
    }
  )
}

# --- LOGS BUCKET ---
data "aws_s3_bucket" "logs_existing" {
  count  = var.use_existing_buckets ? 1 : 0
  bucket = var.existing_logs_bucket
}

resource "aws_s3_bucket" "logs" {
  count  = var.use_existing_buckets ? 0 : 1
  bucket = "${var.project_name}-${var.environment}-logs"

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-logs"
      Purpose     = "logs"
      Environment = var.environment
    }
  )
}

# --- VERSIONING ---
resource "aws_s3_bucket_versioning" "app_data" {
  count  = var.enable_versioning && !var.use_existing_buckets ? 1 : 0
  bucket = aws_s3_bucket.app_data[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  count  = var.enable_versioning && !var.use_existing_buckets ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# --- ENCRYPTION ---
resource "aws_s3_bucket_server_side_encryption_configuration" "app_data" {
  count  = var.enable_encryption && !var.use_existing_buckets ? 1 : 0
  bucket = aws_s3_bucket.app_data[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  count  = var.enable_encryption && !var.use_existing_buckets ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# --- ALB LOGGING POLICY ---
resource "aws_s3_bucket_policy" "logs" {
  count  = var.use_existing_buckets ? 0 : 1
  bucket = aws_s3_bucket.logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs[0].arn}/*"
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.logs[0].arn
      }
    ]
  })
}

# --- REPLICATION ---
resource "aws_s3_bucket_replication_configuration" "app_data" {
  count  = var.enable_replication && !var.use_existing_buckets && var.replication_role_arn != "" ? 1 : 0
  bucket = aws_s3_bucket.app_data[0].id
  role   = var.replication_role_arn

  rule {
    id     = "replicate-all"
    status = "Enabled"

    filter {}

    destination {
      bucket        = var.replication_destination_bucket_arn
      storage_class = "STANDARD"
    }

    delete_marker_replication {
      status = "Enabled"
    }
  }

  depends_on = [aws_s3_bucket_versioning.app_data]
}
