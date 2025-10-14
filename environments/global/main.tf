resource "aws_route53_zone" "main" {
  name = "mydomain.com"

  tags = {
    Project = var.project_name
  }
}

module "dns_failover" {
  source = "../../modules/dns-failover"
  domain_name = "app.mydomain.com"
  hosted_zone_id = aws_route53_zone.main.zone_id
  primary_alb_dns_name = var.primary_alb_dns_name
  primary_alb_zone_id = var.primary_alb_zone_id
  project_name = var.project_name
  secondary_alb_dns_name = var.secondary_alb_dns_name
  secondary_alb_zone_id = var.secondary_alb_zone_id
  sns_topic_arn = module.notifications.topic_arn
}