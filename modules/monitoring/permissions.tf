resource "aws_lambda_permission" "allow_cloudwatch_invocation" {
  statement_id  = "AllowExecutionFromCloudWatchAlarm"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_failover_arn
  principal     = "events.amazonaws.com"


  source_arn    = aws_cloudwatch_metric_alarm.alb_critical_failure.arn
}