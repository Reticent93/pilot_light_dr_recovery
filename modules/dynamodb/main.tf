resource "aws_dynamodb_table" "main" {
  name                        = "${var.project_name}-table"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "id"
  stream_enabled              = true
  deletion_protection_enabled = false
  stream_view_type            = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  # Server-side encryption
  server_side_encryption {
    enabled = true
  }

  # Global table - replicate to secondary region
  replica {
    region_name            = var.aws_secondary_region
    point_in_time_recovery = true
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-dynamodb-table"
      Environment = var.environment
    }
  )

  lifecycle {
    prevent_destroy = false  # Set to true in production
  }
}