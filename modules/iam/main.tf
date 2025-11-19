# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-ec2-role"
    }
  )
}

# S3 Access Policy (only if bucket ARN is provided)
resource "aws_iam_role_policy" "s3_access" {
    count = var.s3_bucket_arn != "" ? 1 : 0

  name = "${var.project_name}-s3-access-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = [
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_bucket_arn
        ]
      }
    ]
  })
}

# DynamoDB Access Policy (only if table ARN is provided)
resource "aws_iam_role_policy" "dynamodb_access" {
  count = var.dynamodb_table_arn != "" ? 1 : 0

  name = "${var.project_name}-dynamodb-access-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = [
          var.dynamodb_table_arn,
          "${var.dynamodb_table_arn}/*"
        ]
      }
    ]
  })
}

# CloudWatch Logs Policy
resource "aws_iam_role_policy" "cloudwatch_logs" {
  name = "${var.project_name}-cloudwatch-logs-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# SSM Parameter Store Access
resource "aws_iam_role_policy" "ssm_access" {
  name = "${var.project_name}-ssm-access-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/${var.project_name}/*"
      }
    ]
  })
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-ec2-role"
  role = aws_iam_role.ec2_role.name

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-instance-profile"
    }
  )
}

resource "aws_iam_role_policy" "eip_association" {
  name = "${var.project_name}-eip-association-policy"
  role   = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:AssociateAddress",
          "ec2:DescribeAddresses",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]

  })
}



# S3 Replication
data "aws_iam_policy_document" "s3_replication_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "s3_replication"        {
  name = "${var.project_name}-s3-replication-role"
  assume_role_policy = data.aws_iam_policy_document.s3_replication_assume_role.json

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-s3-replication-role"
      ManagedBy = "terraform"
      Layer     = "global"
    }
  )
}

data "aws_iam_policy_document" "s3_replication_permissions" {
  statement {
    effect = "Allow"
    actions = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
    resources = ["arn:aws:s3:::pilot-light-dr-recovery-primary-app-data"]
  }
  statement {
    effect  = "Allow"
    actions = ["s3:GetObjectVersion", "s3:GetObjectVersionAcl", "s3:GetObjectVersionTagging"]
    resources = ["arn:aws:s3:::pilot-light-dr-recovery-primary-app-data/*"]
  }
  statement {
    effect  = "Allow"
    actions = ["s3:ReplicateObject", "s3:ReplicateDelete", "s3:ReplicateTags"]
    resources = ["arn:aws:s3:::pilot-light-dr-recovery-secondary-app-data/*"]
  }
}

# S3 Replication Policy
resource "aws_iam_role_policy" "s3_replication" {
  name = "${var.project_name}-s3-replication-policy"
  role = aws_iam_role.s3_replication.id
  policy = data.aws_iam_policy_document.s3_replication_permissions.json
}



# IAM Role for Automation Lambda
resource "aws_iam_role" "lambda_failover_role" {
  name = "${var.project_name}-lambda-failover-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  tags = var.common_tags
}

# IAM Policy for Lambda Failover Function
resource "aws_iam_role_policy" "lambda_failover_policy" {
  name   = "${var.project_name}-lambda-failover-policy"
  role   = aws_iam_role.lambda_failover_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt"
        ]
        Effect   = "Allow"
        # Since we don't know the exact key ARN here, we use "*" and scope by service.
        # This allows decryption of any key used by Lambda in the current region.
        Resource = "*"
        Condition = {
          StringEquals = {
            # Corrected the function name in the ViaService condition
            "kms:ViaService" = "lambda.us-east-1.amazonaws.com"
          }
        }
      },
      {
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:UpdateAutoScalingGroup",
          "cloudwatch:PutMetricData",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTargetGroups",
          "sts:GetCallerIdentity"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = var.sns_topic_arn
      },
      {
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "ec2:AssociateAddress",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        "Action": [
          "ec2:AssociateAddress",
          "ec2:DescribeInstances",
          "ec2:DescribeAddresses"
        ]
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}