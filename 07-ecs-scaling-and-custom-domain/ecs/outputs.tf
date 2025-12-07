output "alb_url" {
  value = aws_alb.load_balancer.dns_name
}

output "domain_name" {
  value = data.terraform_remote_state.ssl_state.outputs.domain_name
}