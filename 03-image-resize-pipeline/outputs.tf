output "bucket_arn" {
  value = aws_s3_bucket.uploads.arn
}

output "bucket_name" {
  value = aws_s3_bucket.uploads.bucket
}

output "bucket_domain" {
  value = aws_s3_bucket.uploads.bucket_regional_domain_name
}

output "cdn_domain" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "cdn_id" {
  value = aws_cloudfront_distribution.cdn.id
}