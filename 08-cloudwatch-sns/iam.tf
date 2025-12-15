resource "aws_iam_role" "ec2" {
  assume_role_policy = data.aws_iam_policy_document.assume_ec2_role.json
}

data "aws_iam_policy_document" "assume_ec2_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}