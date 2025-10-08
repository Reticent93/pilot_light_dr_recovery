output "alb_sg_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id  # ← This is what gets exposed!
}

output "app_tier_sg_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.app_tier.id
}

