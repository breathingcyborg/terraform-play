# Assume api gateway role
resource "aws_iam_role" "todos_api" {
  assume_role_policy = data.aws_iam_policy_document.assume_todos_api_role.json
}

data "aws_iam_policy_document" "assume_todos_api_role" {
  statement {
    effect    = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "apigateway.amazonaws.com"
      ]
    }
  }
}

# Invoke lambda
resource "aws_iam_policy" "todos_api" {
  policy = data.aws_iam_policy_document.todos_api.json
}

data "aws_iam_policy_document" "todos_api" {
  statement {
    resources = [aws_lambda_function.api_lambda.arn, aws_lambda_function.auth.arn]
    actions = [
      "lambda:InvokeFunction"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "todos_api" {
  role       = aws_iam_role.todos_api.id
  policy_arn = aws_iam_policy.todos_api.arn
}

# Api gateway
resource "aws_apigatewayv2_api" "todos_api" {
  name          = "todos_api"
  protocol_type = "HTTP"
}

# Integration
resource "aws_apigatewayv2_integration" "api" {
  api_id           = aws_apigatewayv2_api.todos_api.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  payload_format_version = "2.0"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.api_lambda.invoke_arn
  timeout_milliseconds   = 30000

  credentials_arn = aws_iam_role.todos_api.arn
}

# Authorizer
resource "aws_apigatewayv2_authorizer" "authorizer" {
  api_id = aws_apigatewayv2_api.todos_api.id
  name   = "authorizer"

  authorizer_type = "REQUEST"
  authorizer_uri  = aws_lambda_function.auth.invoke_arn

  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true

  authorizer_credentials_arn = aws_iam_role.todos_api.arn
}

# Routes
resource "aws_apigatewayv2_route" "seed_route" {
  api_id             = aws_apigatewayv2_api.todos_api.id
  route_key          = "POST /seed"
  target             = "integrations/${aws_apigatewayv2_integration.api.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.authorizer.id
}

resource "aws_apigatewayv2_route" "create_todo_route" {
  api_id             = aws_apigatewayv2_api.todos_api.id
  route_key          = "POST /todos"
  target             = "integrations/${aws_apigatewayv2_integration.api.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.authorizer.id
}

resource "aws_apigatewayv2_route" "list_todo_route" {
  api_id             = aws_apigatewayv2_api.todos_api.id
  route_key          = "GET /todos"
  target             = "integrations/${aws_apigatewayv2_integration.api.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.authorizer.id
}

resource "aws_apigatewayv2_route" "get_todo_route" {
  api_id             = aws_apigatewayv2_api.todos_api.id
  route_key          = "GET /todos/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.api.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.authorizer.id
}

# log group
resource "aws_cloudwatch_log_group" "todos_api_log" {
  log_group_class = "STANDARD"
  name = "todosApiGatewyLogs"
}

data "aws_iam_policy" "AmazonAPIGatewayPushToCloudWatchLogs" {
  name = "AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_role_policy_attachment" "todos_api_cloudwatch" {
  role = aws_iam_role.todos_api.id
  policy_arn = data.aws_iam_policy.AmazonAPIGatewayPushToCloudWatchLogs.arn
}

# stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.todos_api.id
  name        = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.todos_api_log.arn
    # format = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"
    format = "req id $context.requestId extended req id $context.extendedRequestId auth error: $context.authorizer.error auth property: $context.authorizer.property error message: $context.error.message error message string: $context.error.messageString error response type: $context.error.responseType integration error: $context.integration.error integration error message string: $context.integrationErrorMessage"
  }
}
# gateway
# integration
# authorization
# routes
# attach integration and authorization to routes
# default stage maybe