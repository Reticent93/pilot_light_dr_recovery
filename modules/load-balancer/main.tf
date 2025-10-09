resource "aws_lb" "main" {
    name               = "${replace(var.project_name, "_", "-")}-lb"
    internal           = var.internal
    load_balancer_type = "application"
    security_groups    = var.security_group_ids
    subnets            = var.subnet_ids

    enable_deletion_protection = var.enable_deletion_protection

    dynamic "access_logs" {
        for_each = var.enable_access_logs ? [1] : []
        content {
            bucket  = var.access_logs_bucket
            enabled = var.enable_access_logs
        }
    }

    tags = {
        Name = "${replace(var.project_name, "_", "-")}-lb"
    }
}

resource "aws_lb_listener" "main" {
    load_balancer_arn = aws_lb.main.arn
    port              = var.listener_port
    protocol          = var.listener_protocol

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.main.arn
    }
}

resource "aws_lb_target_group" "api" {
    name                 = "${replace(var.project_name, "_", "-")}-api-tg"
    port                 = var.api_target_group_port
    protocol             = var.target_group_protocol
    vpc_id               = var.vpc_id

    health_check {
        enabled             = var.health_check_enabled
        healthy_threshold   = var.healthy_threshold
        unhealthy_threshold = var.unhealthy_threshold
        path                = var.api_health_check_path
        interval            = var.health_check_interval
        timeout             = var.health_check_timeout
        matcher             = var.health_check_matcher
    }

    tags = merge(var.tags,{
            Name = "${replace(var.project_name, "_", "-")}-api-tg"
    })
}


resource "aws_lb_listener_rule" "api" {
    count        = var.enable_api_routing ? 1 : 0
    listener_arn = aws_lb_listener.main.arn
    priority     = var.api_rule_priority

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.api.arn
    }

    condition {
        path_pattern {
            values = var.api_path_patterns
        }
    }
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.main.arn
    port         = 80
    protocol     = "HTTP"

    default_action {
        type = "redirect"
        redirect {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
    }

}


resource "aws_lb_listener" "https" {
    count        = var.enable_https ? 1 : 0
    load_balancer_arn = aws_lb.main.arn
    port         = 443
    protocol     = "HTTPS"
    ssl_policy   = var.ssl_policy
    certificate_arn = var.ssl_certificate_arn

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.main.arn
    }
}

resource "aws_lb_target_group" "main" {
    name                 = "${replace(var.project_name, "_", "-")}-tg"
    port                 = var.target_group_port
    protocol             = var.target_group_protocol
    vpc_id               = var.vpc_id

    health_check {
        enabled             = var.health_check_enabled
        healthy_threshold   = var.healthy_threshold
        unhealthy_threshold = var.unhealthy_threshold
        path                = var.health_check_path
        interval            = var.health_check_interval
        timeout             = var.health_check_timeout
        matcher             = var.health_check_matcher
    }

    tags = merge(var.tags,{
            Name = "${replace(var.project_name, "_", "-")}-tg"
    })
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
    count               = var.enable_cloudwatch_alarms ? 1 : 0
    alarm_name          = "${var.name}-unhealthy-hosts"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 2
    metric_name         = "UnHealthyHostCount"
    namespace           = "AWS/ApplicationELB"
    period              = 60
    statistic           = "Average"
    threshold           = var.unhealthy_host_count_threshold


    alarm_actions = [var.sns_topic_arn]
}