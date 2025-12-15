resource "aws_sns_topic" "cpu_usage" {
  name_prefix = "cpu_usage_alarm"
  fifo_topic  = false
  policy      = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
  }
}

resource "aws_sns_topic_subscription" "cpu_usage_mail" {
  protocol  = "email"
  endpoint  = var.email
  topic_arn = aws_sns_topic.cpu_usage.arn
}