# --------------------------------------------------------
# Autoscaling group, used by ecs capacity provider
# 
# --------------------------------------------------------

# Get ECS Optimized AMI - It has ecs-agent and docker preinstalled

# To get latest image (ami) for the ecs agent, we get parameter named
# /aws/service/ecs/optimized-ami/amazon-linux-2023/recommended
# From SSM Parameter Store
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/retrieve-ecs-optimized_AMI.html
data "aws_ssm_parameter" "ecs_recommended_image" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended"
}

# Extract image id from json value of SSM parameter above
locals {
  ecs_ami_info = jsondecode(data.aws_ssm_parameter.ecs_recommended_image.value)
  ecs_ami_id   = local.ecs_ami_info.image_id
}

# ssh key, useful for debugging
resource "aws_key_pair" "ssh-key" {
  key_name   = "tf-play-ssh"
  public_key = file("../tf-play-ssh-key.pub")
}

# Launch template for ec2 instances, of ASG
# This ec2 instance would run ecs-agent using docker
# ECS Agent is responsible for registering this ec2 instance to ecs cluster
# and other things such as pulling docker image and starting ecs task
resource "aws_launch_template" "launch_template" {
  name          = "tf_play_5_lt"
  image_id      = local.ecs_ami_id
  instance_type = "t2.micro"

  key_name = aws_key_pair.ssh-key.key_name

  # We prefer ipv6
  network_interfaces {
    primary_ipv6       = true
    ipv6_address_count = 1
    security_groups = [ aws_security_group.ec2_sg.id ]
  }

  user_data = base64encode(<<-EOT
    #!/bin/bash
    echo "ECS_CLUSTER=${aws_ecs_cluster.cluster.name}" >> /etc/ecs/ecs.config
    echo "ECS_INSTANCE_IP_COMPATIBILITY=ipv6" >> /etc/ecs/ecs.config
    echo "ECS_LOGLEVEL=debug" >> /etc/ecs/ecs.config
    echo "ECS_LOGLEVEL_ON_INSTANCE=debug" >> /etc/ecs/ecs.config
    EOT
  )

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_container_instance.arn
  }
}

resource "aws_autoscaling_group" "asg" {
  min_size            = 0
  max_size            = 2
  vpc_zone_identifier = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

  launch_template {
    id = aws_launch_template.launch_template.id
  }
  # required for terraform  
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}