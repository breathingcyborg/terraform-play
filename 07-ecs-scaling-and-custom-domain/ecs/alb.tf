# ----------------------------
# Load balancer for ecs service
# it will forward requests from clients to alb target group
# the ecs service would register tasks to the same target group
# ----------------------------
resource "aws_alb" "load_balancer" {
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  internal           = false

  # for now deleting instance is good enough
  # with this flag enabled, terraform destory gets stuck
  enable_deletion_protection = false
}

# listener to receive http request and forward it to target group
# ecs service would dynamically register task to this target group
resource "aws_lb_listener" "http" {
  port              = 80
  protocol          = "HTTP"
  load_balancer_arn = aws_alb.load_balancer.arn
  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_alb_target_group.tg.arn
      }
    }
  }
}

# listener to receive https request and forward it to target group
# ecs service would dynamically register task to this target group
resource "aws_lb_listener" "https" {
  port              = 443
  protocol          = "HTTPS"
  load_balancer_arn = aws_alb.load_balancer.arn

  # ssl config
  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.terraform_remote_state.ssl_state.outputs.certificate_arn

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_alb_target_group.tg.arn
      }
    }
  }
}



# alb target group
# load balancer listener forwards request to this target group
# ecs service would register tasks with this target group
resource "aws_alb_target_group" "tg" {
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id
  protocol    = "HTTP"
  port        = 80
}