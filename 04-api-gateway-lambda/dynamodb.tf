resource "aws_dynamodb_table" "todos_table" {
  name = "todos2"

  hash_key     = "id" # partition key
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "N"
  }

  attribute {
    name = "userId"
    type = "N"
  }

  attribute {
    name = "createdAt"
    type = "N"
  }

  global_secondary_index {
    name            = "userId-createdAt-index"
    hash_key        = "userId"
    range_key       = "createdAt"
    projection_type = "ALL"
  }
}

resource "aws_iam_policy" "dynamo_read_write" {
  policy = data.aws_iam_policy_document.dynamo_read_write.json
}

data "aws_iam_policy_document" "dynamo_read_write" {
  statement {
    effect = "Allow"
    actions = [
      # single item operations
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",

      # search operations
      "dynamodb:Scan",
      "dynamodb:Query",

      # batch insert
      "dynamodb:BatchWriteItem"
    ]
    resources = [
      "${aws_dynamodb_table.todos_table.arn}",
      "${aws_dynamodb_table.todos_table.arn}/index/*"
    ]
  }
}