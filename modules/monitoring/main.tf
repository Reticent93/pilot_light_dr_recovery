# CloudWatch Dashboard
# This dashboard focuses on performance metrics only.
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      # ALB Health Status
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", var.alb_arn_suffix, { label = "Healthy" }],
            [".", "UnHealthyHostCount", ".", ".", { label = "Unhealthy" }]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "ALB Host Health"
        }
      },
      # ASG Capacity
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", var.asg_name, { label = "Desired" }],
            [".", "GroupInServiceInstances", ".", ".", { label = "In Service" }]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "ASG Instances"
        }
      },
      # Response Time
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "Response Time"
        }
      },
      # CPU Utilization
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "CPU Utilization"
        }
      }
    ]
  })
}

# PERFORMANCE ALARMS ONLY (NOT AVAILABILITY)

# Alarm 1: High Response Time (Performance)
resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  alarm_name          = "${var.project_name}-${var.environment}-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = var.response_time_threshold
  alarm_description   = "Application response time is degraded"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = var.sns_topic_arns

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-high-response-time"
    Type = "Performance"
  })
}

# Alarm 2: High CPU (Performance)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EC2 instances have high CPU - may need scaling"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = var.sns_topic_arns

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-high-cpu"
    Type = "Performance"
  })
}

# Alarm 3: DynamoDB Throttling (Performance)
resource "aws_cloudwatch_metric_alarm" "dynamodb_throttled" {
  alarm_name          = "${var.project_name}-${var.environment}-dynamodb-throttled"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UserErrors"
  namespace           = "AWS/DynamoDB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "DynamoDB requests are being throttled"

  dimensions = {
    TableName = var.dynamodb_table_name
  }

  alarm_actions = var.sns_topic_arns

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-dynamodb-throttled"
    Type = "Performance"
  })
}

# This CRITICAL alarm triggers the DR Failover (ALARM state) and Failback (OK state).
resource "aws_cloudwatch_metric_alarm" "alb_critical_failure" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-critical-failure"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "CRITICAL: Primary ALB has no healthy hosts - triggers DR failover"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  # Failover Action: NOW ONLY TARGETS SNS TOPIC. The SNS topic will invoke the Lambda.
  alarm_actions = var.sns_topic_arns

  # Failback Action: NOW ONLY TARGETS SNS TOPIC. The SNS topic will invoke the Lambda.
  ok_actions    = var.sns_topic_arns

  tags = merge(var.common_tags, {
    Name     = "${var.project_name}-${var.environment}-alb-critical-failure"
    Severity = "CRITICAL"
    Triggers = "DR-Failover/Failback"
  })
}
