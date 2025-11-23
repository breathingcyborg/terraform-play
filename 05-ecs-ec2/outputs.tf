output "region" {
  value = aws_ecr_repository.repo.region
}

output "repository_url" {
  description = "repo url"
  value       = aws_ecr_repository.repo.repository_url
}

output "alb_url" {
  value = aws_alb.load_balancer.dns_name
}