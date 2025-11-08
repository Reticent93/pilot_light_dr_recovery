# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "5.81.0"
#     }
#   }
# }
# resource "aws_route53_health_check" "primary" {
#   type = "HTTP"
#     fqdn = var.primary_alb_dns_name
#     port = 80
#     resource_path = var.health_check_path
#     request_interval = 30
#     failure_threshold = 3
#
#   tags = merge(var.common_tags, {
#     Name = "${var.project_name}-primary-health-check"
#   })
#
# }
#
# # Primary Region DNS Record
# resource "aws_route53_record" "primary" {
#   zone_id = var.hosted_zone_id
#   name    = var.domain_name
#   type    = "A"
#   set_identifier = "primary"
#
#   alias {
#     name                   = var.primary_alb_dns_name
#     zone_id                = var.primary_alb_zone_id
#     evaluate_target_health = true
#   }
#
#   failover_routing_policy {
#     type = "PRIMARY"
#   }
#
#   health_check_id = aws_route53_health_check.primary.id
# }
#
# # Secondary Region DNS Record
# resource "aws_route53_record" "secondary" {
#   zone_id = var.hosted_zone_id
#   name    = var.domain_name
#   type    = "A"
#   set_identifier = "secondary"
#
#   alias {
#     name                   = var.secondary_alb_dns_name
#     zone_id                = var.secondary_alb_zone_id
#     evaluate_target_health = false
#   }
#
#   failover_routing_policy {
#     type = "SECONDARY"
#   }
# }
#
# resource "aws_cloudwatch_metric_alarm" "primary_alb_unhealthy_hosts" {
#     alarm_name          = "${var.project_name}-primary-alb-unhealthy-hosts"
#     comparison_operator = "LessThanThreshold"
#     evaluation_periods  = 2
#     metric_name         = "HealthCheckStatus"
#     namespace           = "AWS/Route53"
#     period              = 60
#     statistic           = "Minimum"
#     threshold           = 1
#     alarm_description = "Primary region health check failed - failover triggered"
#
#     dimensions = {
#         HealthCheckId = aws_route53_health_check.primary.id
#     }
#
#    alarm_actions = [var.sns_topics_arn]
# }
#
# resource "aws_cloudwatch_metric_alarm" "primary_health_failed" {
#   alarm_name          = "${var.project_name}-primary-health-failed"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods  = 1
#     metric_name         = "HealthCheckStatus"
#     namespace           = "AWS/Route53"
#     period              = 60
#     statistic           = "Minimum"
#     threshold           = 1
#     treat_missing_data = "breaching"
#     alarm_description = "Primary region health check failed - failover triggered"
#
#     dimensions = {
#         HealthCheckId = aws_route53_health_check.primary.id
#     }
# }
#
# resource "aws_cloudwatch_dashboard" "dns_failover_status" {
#   dashboard_name = "${var.project_name}-dns-failover-status"
#   dashboard_body = jsonencode({
#     widgets = [
#       {
#         type = "metric"
#         x = 0
#         y = 0
#         width = 12
#         height = 6
#         properties = {
#           metrics = [
#             ["AWS/Route53", "HealthCheckStatus", "HealthCheckId", aws_route53_health_check.primary.id]
#           ]
#           title = "Route 53 health checks"
#           region = var.aws_region
#           stat = "Minimum"
#           period = 60
#         }
#       }
#     ]
#   })
# }