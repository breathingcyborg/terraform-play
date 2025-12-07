# --------------------------------------------
# 1. Default role of ecs agent running on ec2
# * It's used for general (not task specific) actions
# * like registering ec2 instance to cluster, reporting usage metrics etc
# -------------------------------------------
data "aws_iam_policy" "ec2_container_instance" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role" "ec2_container_instance" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_container_instance" {
  policy_arn = data.aws_iam_policy.ec2_container_instance.arn
  role       = aws_iam_role.ec2_container_instance.id
}

# any ec2 instance launched with this profile, will assume this role
resource "aws_iam_instance_profile" "ec2_container_instance" {
  name = aws_iam_role.ec2_container_instance.name
  role = aws_iam_role.ec2_container_instance.name
}

# --------------------------------------------
# 2. Role for the same ecs agent as above
# but for task specific actions
# like pulling images from container registry etc
# agent would assume this role when performing task specific actions
# -------------------------------------------
data "aws_iam_policy" "task_execution" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task_def_execution" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  policy_arn = data.aws_iam_policy.task_execution.arn
  role       = aws_iam_role.task_def_execution.id
}

# --------------------------------------------
# 3. Role for our container
# any permission our container needs should be added here
# -------------------------------------------
resource "aws_iam_role" "task" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}
