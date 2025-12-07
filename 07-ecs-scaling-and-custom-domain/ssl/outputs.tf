output "validation_options" {
  value = aws_acm_certificate.tfplay7.domain_validation_options
}

output "certificate_arn" {
  value = aws_acm_certificate.tfplay7.arn
}

output "domain_name" {
  value = aws_acm_certificate.tfplay7.domain_name
}