resource "aws_cloudwatch_metric_alarm" "primary_health_failed" {
  alarm_name = "${var.project_name}-primary-health-failed"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1
  metric_name = "HealthCheckStatus"
  namespace = "AWS/Route53"
  period = 60
  statistic = "Minimum"
  threshold = 1
  treat_missing_data = "breaching"

  dimensions = {
    HealthCheckId = aws_route53_health_check.primary.id
  }

  alarm_actions = [var.sns_topics_arn]
  alarm_description = "Primary region health check failed - failover triggered"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-primary-health-failed"
  })
}


resource "aws_cloudwatch_metric_alarm" "dns_query_volume_low" {
  alarm_name          = "${var.project_name}-dns-query-volume-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DNSQueries"
  namespace           = "AWS/Route53"
  period              = 300
  statistic           = "Sum"
  threshold           = 10

  alarm_actions = [var.sns_topics_arn]
  alarm_description = "DNS query volume is below the expected threshold"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-dns-query-volume-low"
  })
}


resource "aws_cloudwatch_metric_alarm" "primary_health_recovered" {
  alarm_name          = "${var.project_name}-primary-health-recovered"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  evaluation_periods  = 2
  threshold           = 1

  dimensions = {
    HealthCheckId = aws_route53_health_check.primary.id
  }

  alarm_actions = [var.sns_topics_arn]
  alarm_description = "Primary region health check recovered - failback can be initiated"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-primary-health-recovered"
  })
}

resource "aws_cloudwatch_dashboard" "dns_failover_status" {
  dashboard_name = "${var.project_name}-dns-failover-status"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Route53", "HealthCheckStatus", { stat = "Minimum", label = "Primary Health Status" }]
          ]
          period = 60
          stat   = "Minimum"
          region = "us-east-1"
          title  = "🏥 Primary Region Health Status"
          yAxis = {
            left = {
              min = 0
              max = 1
            }
          }
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Route53", "DNSQueries", { stat = "Sum", label = "DNS Queries" }]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "📊 DNS Query Volume"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Route53", "HealthCheckPercentageHealthy", { stat = "Average", label = "Health Check % Healthy" }]
          ]
          period = 60
          stat   = "Average"
          region = "us-east-1"
          title  = "📈 Health Check Percentage"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type = "log"
        properties = {
          query   = "fields @timestamp, @message | filter @message like /failover|health/ | stats count() as events by bin(5m)"
          region  = "us-east-1"
          title   = "🔔 Failover Events (Last 24h)"
        }
      }
    ]
  })
}
dashboard_body = jsonencode({
  widgets = [
    {
      type = "metric"
      x = 0
      y = 0
      width = 12
      height = 6
      properties = {
        metrics = [
          ["AWS/Route53", "HealthCheckStatus", "HealthCheckId", aws_route53_health_check.primary.id]
        ]
        view = "timeSeries"
        stacked = false
        region = var.aws_region
        stat = "Minimum"
        period = 60
        title = "DNS Failover Status"
      }
    }
  ]
})


resource "aws_cloudwatch_event_rule" "alarm_state_change" {
  name        = "${var.project_name}-alarm-state-change"
  description = "Capture all CloudWatch alarm state changes"

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    detail = {
      alarmName = [
        aws_cloudwatch_metric_alarm.primary_health_failed.alarm_name,
        aws_cloudwatch_metric_alarm.primary_health_recovered.alarm_name,
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "alarm_sns" {
  rule      = aws_cloudwatch_event_rule.alarm_state_change.name
  target_id = "AlarmToSNS"
  arn       = var.sns_topics_arn

  input_transformer {
    input_paths = {
      alarm  = "$.detail.alarmName"
      state  = "$.detail.state.value"
      reason = "$.detail.state.reasonData"
    }
    input_template = jsonencode({
      AlarmName = "<alarm>"
      NewState  = "<state>"
      Reason    = "<reason>"
    })
  }
}