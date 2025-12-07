output "alb_url" {
  value = aws_alb.load_balancer.dns_name
}