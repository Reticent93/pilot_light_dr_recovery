resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for the ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
        Name = "${var.environment}-alb-sg"
        Environment = var.environment
        Project = var.project_name
    }

}

resource "aws_security_group" "app_tier" {
  name        = "${var.project_name}-app-tier-sg"
  description = "Security group for the application tier"
  vpc_id      = var.vpc_id

    ingress {
        description = "HTTP"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        security_groups = [aws_security_group.alb.id]
    }

    egress {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-app-tier-sg"
        Environment = var.environment
        Project = var.project_name
    }
}



