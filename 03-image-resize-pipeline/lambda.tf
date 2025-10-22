data "archive_file" "code" {
  type             = "zip"
  source_dir       = "${path.module}/code"
  output_file_mode = "0666"
  output_path      = "${path.module}/code.zip"
}

resource "aws_lambda_function" "image_resize_lambda" {
  role          = aws_iam_role.image_resize_lambda.arn
  function_name = "image_resize_lambda"
  filename      = data.archive_file.code.output_path
  handler       = "index.handler" # index is file name, handler is export name
  runtime       = "nodejs20.x"
  publish       = true
  timeout       = 30 # 30s is the max timeout of lambda@edge
}

# Role For Image Resize Lambda
resource "aws_iam_role" "image_resize_lambda" {
  # allow lambda and edge lambda to assume this role
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid    = "AllowLambdaRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
  statement {
    sid    = "AllowEdgeLambdaRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["edgelambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# 1. attach basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_execution_policy" {
  role       = aws_iam_role.image_resize_lambda.id
  policy_arn = data.aws_iam_policy.lambda_execution_policy.arn
}

data "aws_iam_policy" "lambda_execution_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 2. attach bucket read write policy
resource "aws_iam_role_policy_attachment" "uploads_read_write" {
  role       = aws_iam_role.image_resize_lambda.id
  policy_arn = aws_iam_policy.uploads_read_write.arn
}

resource "aws_iam_policy" "uploads_read_write" {
  policy = data.aws_iam_policy_document.uploads_read_write.json
}

data "aws_iam_policy_document" "uploads_read_write" {
  statement {
    sid = "AllowReadWrite"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.uploads.arn}/*"]
  }

  statement {
    sid = "AllowList"
    actions = [
      "s3:ListBucket",
    ]
    resources = [aws_s3_bucket.uploads.arn]
  }
}
