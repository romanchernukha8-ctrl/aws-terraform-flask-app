# Get default subnets (used to place Load Balancer and instances)
data "aws_subnets" "default" {}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Application Load Balancer
# Distributes incoming HTTP traffic across backend instances
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.web_sg.id]
}

# Target group for backend servers
# Instances from Auto Scaling Group will be registered here
resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  # Health check to verify instance availability
  health_check {
    path = "/"
    port = "80"
  }
}

# Listener for HTTP traffic
# Forwards requests from ALB to target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}