data "aws_ami" "amazon_linux" {
    most_recent = true
    owners = ["amazon"]
  filter {
        name   = "name"
      values = ["al2023-ami-*-x86_64"]
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

  user_data = base64encode(<<-EOF
    #!/bin/bash
    exec > >(tee /var/log/user-data.log) 2>&1
    set -x

    # Update and install httpd
    dnf update -y || { echo "DNF update failed"; exit 1; }
    dnf install -y httpd || { echo "HTTPD install failed"; exit 1; }

    # Configure httpd
    sed -i 's/^KeepAliveTimeout 5/KeepAliveTimeout 65/' /etc/httpd/conf/httpd.conf

    # Start and enable httpd
    systemctl start httpd || { echo "HTTPD start failed"; exit 1; }
    systemctl enable httpd

    # Wait for httpd to be active
    timeout 60 bash -c 'until systemctl is-active httpd; do sleep 5; done' || { echo "HTTPD did not start in time"; exit 1; }

    # Create web content
    echo "OK" > /var/www/html/health
    echo "<h1>Primary Region - Instance $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</h1>" > /var/www/html/index.html

    # Associate EIP
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    ALLOCATION_ID="${var.eip_allocation_id}"
    /usr/bin/aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id $ALLOCATION_ID --allow-reassociation || echo "EIP association failed"

    echo "User data script completed successfully"
    EOF
  )

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

  health_check_grace_period = 600
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

resource "aws_eip" "dr_bastion_eip" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-dr-bastion-eip"
    Environment = var.environment
    # Add a tag to easily identify the purpose of this static EIP
    Purpose     = "ASG-Bastion-Host-Access"
  }
}