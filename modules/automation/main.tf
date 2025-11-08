# Lambda Function for Failover
data "archive_file" "failover_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/failover.py"
  output_path = "${path.module}/lambda/failover.zip"
}

resource "aws_lambda_function" "failover" {
  filename         = data.archive_file.failover_lambda.output_path
  function_name    = "${var.project_name}-failover"
  role            = var.lambda_failover_role_arn
  handler         = "failover.lambda_handler"
  source_code_hash = data.archive_file.failover_lambda.output_base64sha256
  runtime         = "python3.11"
  timeout         = 300

  environment {
    variables = {
      SECONDARY_REGION    = var.secondary_region
      SECONDARY_ASG_NAME  = var.secondary_asg_name
      DESIRED_CAPACITY    = var.failover_desired_capacity
      SNS_TOPIC_ARN      = var.sns_topic_arn
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-dr-failover"
  })
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "failover_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.failover.function_name}"
  retention_in_days = 30

  tags = var.common_tags
}


# EventBridge Rule - Trigger on Alarm State Change
resource "aws_cloudwatch_event_rule" "primary_unhealthy" {
  name        = "${var.project_name}-primary-unhealthy"
  description = "Triggers when primary ALB alarm goes to ALARM state"

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    detail = {
      alarmName = [var.primary_alb_alarm_name]
      state = {
        value = ["ALARM"]
      }
    }
  })

  tags = var.common_tags
}

# EventBridge Target - Invoke Lambda
resource "aws_cloudwatch_event_target" "trigger_failover" {
  rule      = aws_cloudwatch_event_rule.primary_unhealthy.name
  target_id = "TriggerFailoverLambda"
  arn       = aws_lambda_function.failover.arn
}

# Permission for EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.failover.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.primary_unhealthy.arn
}
