resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm" {
  alarm_name          = "ec2_cpu_alarm"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 70
  evaluation_periods  = 1
  alarm_actions       = [aws_sns_topic.cpu_usage.arn]
  statistic           = "Average"
  period              = 60
  dimensions = {
    InstanceId = aws_instance.ec2.id
  }
}
