data "aws_ami" "amazon_linux" {
    most_recent = true
    owners = ["amazon"]
  filter {
        name   = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

# Launch Template
resource "aws_launch_template" "main" {
  name_prefix   = "${var.environment}-${var.project_name}-lt"
  description   = "Launch Template for ${var.project_name}"
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name


  iam_instance_profile {
    name = var.iam_instance_profile
  }

  # user_data = base64encode(templatefile("${path.module}/user_data.sh", {
  #   environment = var.environment
  #   project_name = var.project_name
  #   region = var.aws_region
  #   s3_bucket = var.s3_bucket_name
  # }))

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true

    }
  }

  dynamic "block_device_mappings" {
    for_each = var.additional_ebs_volume_size > 0 ? [1] : []
    content {
        device_name = "/dev/xvdf"

        ebs {
            volume_size = var.additional_ebs_volume_size
            volume_type = "gp3"
            encrypted   = true
            delete_on_termination = true
        }
    }
  }


  network_interfaces {
    associate_public_ip_address = var.associate_public_ip
    security_groups             = var.security_group_ids
    delete_on_termination       = true
    subnet_id                   = null
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

    monitoring {
        enabled = var.detailed_monitoring
    }

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.common_tags, {
      Name        = "${var.environment}-${var.project_name}-instance"
      Environment = var.environment
      LaunchedBy  = "ASG"
    })
  }

    tag_specifications {
        resource_type = "volume"
        tags = merge(var.common_tags, {
            Name = "${var.environment}-${var.project_name}-volume"
            Environment = var.environment
        })
    }

  tags = merge(var.common_tags, {
    Name        = "${var.environment}-${var.project_name}-lt"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name_prefix         = "${var.environment}-${var.project_name}-asg-"
  max_size            = var.max_size
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids

  target_group_arns = var.target_group_arns

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = var.min_healthy_percentage
      instance_warmup        = var.instance_warmup
    }
    triggers = ["desired_capacity"]
  }

  termination_policies = var.termination_policies

  health_check_grace_period = 300
  health_check_type         = "ELB"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  dynamic "tag" {
    for_each = merge(var.common_tags, {
        Name        = "${var.environment}-${var.project_name}-asg"
        Environment = var.environment
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  dynamic "initial_lifecycle_hook" {
    for_each = var.enable_lifecycle_hooks ? [1] : []
    content {
      name = "instance-termination-hook"
      default_result = "ABANDON"
      heartbeat_timeout = 300
      lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"

      notification_target_arn = var.sns_topic_arn
        role_arn                = var.lifecycle_hook_role_arn
    }
  }

    protect_from_scale_in = var.protect_from_scale_in

    lifecycle {
        create_before_destroy = true
        ignore_changes = [desired_capacity]
    }
}

