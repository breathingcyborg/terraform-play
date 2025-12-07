
# The dimension to scale (ecs service count)
resource "aws_appautoscaling_target" "ecs_autoscaling_target" {
  service_namespace  = "ecs"
  min_capacity       = 1
  max_capacity       = 3
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
}

# The scaling policy, defining when/how to scale out and scale in
resource "aws_appautoscaling_policy" "ecs_service_autoscaling" {
  name               = "ecs_service_autoscaling"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = "ecs"
  scalable_dimension = aws_appautoscaling_target.ecs_autoscaling_target.scalable_dimension
  resource_id        = aws_appautoscaling_target.ecs_autoscaling_target.resource_id

  target_tracking_scaling_policy_configuration {

    # Amount of time, in seconds, after a scale in activity completes before another scale in activity can start.
    scale_in_cooldown = 60

    # Amount of time, in seconds, after a scale out activity completes before another scale out activity can start.
    scale_out_cooldown = 60

    predefined_metric_specification {

      # Track request count per minute
      # We dont specify the time resolution manually
      # It uses the cloudwatch metric's resolution
      # The resolution of ALB's RequestCountPerTarget metric 
      # is one minute
      predefined_metric_type = "ALBRequestCountPerTarget"

      # Format: app/<load-balancer-name>/<load-balancer-id>/targetgroup/<target-group-name>/<target-group-id>
      # .id is arn in terraform
      # aws_alb.load_balancer.arn_suffix is app/<load-balancer-name>/<load-balancer-id>
      # aws_alb_target_group.tg.arn_suffix is targetgroup/<target-group-name>/<target-group-id>
      resource_label = "${aws_alb.load_balancer.arn_suffix}/${aws_alb_target_group.tg.arn_suffix}"
    }

    # 60 request in last minute
    target_value = 60
  }
}