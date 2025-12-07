output "repo_url" {
  description = "repo url"
  value       = aws_ecr_repository.repo.repository_url
}

output "repo_region" {
  description = "repos aws region"
  value       = aws_ecr_repository.repo.region
}

output "repo_name" {
  description = "repos name"
  value       = aws_ecr_repository.repo.name
}

output "registry_id" {
  description = "registry id"
  value       = aws_ecr_repository.repo.registry_id
}

