# ROUTE 53 HEALTH CHECK
resource "aws_route53_health_check" "primary" {
  fqdn              = var.primary_alb_dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = var.health_check_path
  failure_threshold = 3
  request_interval  = 30

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-primary-health-check"
  })
}


# DNS RECORDS - FAILOVER ROUTING

# Primary Region Record
resource "aws_route53_record" "primary" {
  zone_id        = var.hosted_zone_id
  name           = var.domain_name
  type           = "A"
  set_identifier = "primary"

  failover_routing_policy {
    type = "PRIMARY"
  }

  alias {
    name                   = var.primary_alb_dns_name
    zone_id                = var.primary_alb_zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.primary.id
}

# Secondary Region Record
resource "aws_route53_record" "secondary" {
  zone_id        = var.hosted_zone_id
  name           = var.domain_name
  type           = "A"
  set_identifier = "secondary"

  failover_routing_policy {
    type = "SECONDARY"
  }

  alias {
    name                   = var.secondary_alb_dns_name
    zone_id                = var.secondary_alb_zone_id
    evaluate_target_health = false
  }
}


# FAILOVER ALARM
resource "aws_cloudwatch_metric_alarm" "failover_triggered" {
  alarm_name          = "${var.project_name}-FAILOVER-TRIGGERED"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  treat_missing_data  = "breaching"

  dimensions = {
    HealthCheckId = aws_route53_health_check.primary.id
  }

  alarm_description = "DISASTER RECOVERY FAILOVER TRIGGERED - Traffic now routing to secondary region"
  alarm_actions     = [var.sns_topics_arn]

  tags = merge(var.common_tags, {
    Name     = "${var.project_name}-failover-alarm"
    Severity = "CRITICAL"
    Purpose  = "DR-Failover"
  })
}

