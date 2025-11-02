# Role for api lambda
resource "aws_iam_role" "api_lambda" {
  # policy to assume role
  assume_role_policy = data.aws_iam_policy_document.assume_labmda_role.json
}

# policy to write to logs
resource "aws_iam_role_policy_attachment" "api_lambda_basic" {
  role       = aws_iam_role.api_lambda.id
  policy_arn = data.aws_iam_policy.lambda_basic_execution.arn
}

# policy to access dynamobd
resource "aws_iam_role_policy_attachment" "api_lambda_dynamodb" {
  role       = aws_iam_role.api_lambda.id
  policy_arn = aws_iam_policy.dynamo_read_write.arn
}

# Actual function
data "archive_file" "api_lambda" {
  type             = "zip"
  source_dir       = "${path.module}/api-lambda"
  output_file_mode = "0666"
  output_path      = "${path.module}/api-lambda.zip"
}

resource "aws_cloudwatch_log_group" "api_log_group" {
  name = "/aws/lambda/todosApiLambda"
}

resource "aws_lambda_function" "api_lambda" {
  function_name = "api_lambda"
  filename      = data.archive_file.api_lambda.output_path
  role          = aws_iam_role.api_lambda.arn
  runtime       = "nodejs22.x"
  handler       = "index.handler"
  timeout       = 30 # seconds
  logging_config {
    log_group = "/aws/lambda/todosApiLambda"
    log_format = "Text"
  }
  source_code_hash = data.archive_file.api_lambda.output_sha256
}