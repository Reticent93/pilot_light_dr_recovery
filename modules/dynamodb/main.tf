resource "aws_dynamodb_table" "main" {
  name = "${var.project_name}-table"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "id"
    stream_enabled = true
    deletion_protection_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

    attribute {
      name = "id"
      type = "S"
    }

    point_in_time_recovery {
      enabled = true
    }

    replica {
      region_name = var.dr_region
    }

    tags = {
      Name = "${var.project_name}-dynamodb-table"
        Environment = var.environment
    }
}

