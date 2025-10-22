# Uploads bucket
resource "aws_s3_bucket" "uploads" {
  bucket        = var.bucket_name
  force_destroy = true
}

# Public access for uploads bucket
resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket                  = aws_s3_bucket.uploads.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

# Uploads bucket policy
resource "aws_s3_bucket_policy" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  policy = data.aws_iam_policy_document.uploads.json
}

data "aws_iam_policy_document" "uploads" {

  statement {
    sid = "AllowPublicReadAccess"
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.uploads.arn}/*"
    ]
  }

  statement {
    sid = "AllowCloudfrontRead"

    effect = "Allow"

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.uploads.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  }

  statement {
    sid = "AllowCloudfrontList"

    effect = "Allow"

    actions = ["s3:ListBucket"]

    resources = [
      aws_s3_bucket.uploads.arn
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  }
}
