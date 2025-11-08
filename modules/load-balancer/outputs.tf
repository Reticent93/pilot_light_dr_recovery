output "target_group_arn" {
  description = "ARN of the target group"
  value = aws_lb_target_group.main.arn
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value = aws_lb.main.arn
}

output "load_balancer_dns_name" {
    description = "DNS name of the load balancer"
  value = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
    description = "Zone ID of the load balancer"
  value = aws_lb.main.zone_id
}

output "listener_arn" {
    description = "ARN of the load balancer listener"
  value = aws_lb_listener.main.arn
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the ALB (for CloudWatch metrics)"
  value       = aws_lb.main.arn_suffix
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arns" {
  description = "List of target group ARNs (for ASG attachment)"
  value       = [aws_lb_target_group.main.arn]
}

output "api_target_group_arn" {
  description = "ARN of the API target group"
  value       = aws_lb_target_group.api.arn
}