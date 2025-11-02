
# Allow lambda to write to cloudwatch
data "aws_iam_policy" "lambda_basic_execution" {
  name = "AWSLambdaBasicExecutionRole"
}

# Policy to allow lambda to assume role
# This would be attached directly to role for lambda
data "aws_iam_policy_document" "assume_labmda_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
