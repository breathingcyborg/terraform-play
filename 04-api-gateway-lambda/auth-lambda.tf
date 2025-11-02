# Role for auth lambda
resource "aws_iam_role" "auth_lambda" {
  assume_role_policy = data.aws_iam_policy_document.assume_labmda_role.json
}

# Policy to write to logs
resource "aws_iam_role_policy_attachment" "auth_lambda" {
  policy_arn = data.aws_iam_policy.lambda_basic_execution.arn
  role       = aws_iam_role.auth_lambda.id
}

# Actual function
data "archive_file" "auth_lambda" {
  type             = "zip"
  source_dir       = "${path.module}/auth-lambda"
  output_file_mode = "0666"
  output_path      = "${path.module}/auth-lambda.zip"
}

resource "aws_cloudwatch_log_group" "auth_log_group" {
  name = "/aws/lambda/todosApiAuthLambda"
}

resource "aws_lambda_function" "auth" {
  function_name = "auth_lambda"
  filename      = data.archive_file.auth_lambda.output_path
  role          = aws_iam_role.auth_lambda.arn
  runtime       = "nodejs22.x"
  handler       = "index.handler"
  source_code_hash = data.archive_file.auth_lambda.output_sha256
  logging_config {
    log_format = "Text"
    log_group = "/aws/lambda/todosApiAuthLambda"
  }
}