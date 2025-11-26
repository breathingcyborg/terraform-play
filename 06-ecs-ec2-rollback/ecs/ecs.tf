# --------------------------------------------------------
# ECS Cluster
# --------------------------------------------------------
resource "aws_ecs_cluster" "cluster" {
  name = "tf_play_6_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# trunking allows more network interfaces (eni), 
# to be attached to an ec2 instance
# so more tasks can run on same ec2 instance
# applies to awsvpc network mode only
resource "aws_ecs_account_setting_default" "awsvpc_trunking_default" {
  name  = "awsvpcTrunking"
  value = "enabled"
}

# --------------------------------------------------------
# ECS Service - maintains task count and 
# registers container instance with load balancers target group
# --------------------------------------------------------
resource "aws_ecs_service" "service" {
  name            = "tf_play_6_ecs_service"
  task_definition = aws_ecs_task_definition.task_def.arn
  cluster         = aws_ecs_cluster.cluster.id
  desired_count   = 1

  # rolling updates
  deployment_configuration {
    strategy = "ROLLING"
  }

  # rollback on failure
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # Network config for the tasks created by this service
  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.container_sg.id]
    subnets          = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  }

  # Load balancer for task
  load_balancer {
    target_group_arn = aws_alb_target_group.tg.arn
    container_name   = "tf_play_6_hello_world"
    container_port   = 3000
  }
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/tf_play_6_hello_world"
}

# --------------------------------------------------------
# ECS Task Definition - Blueprint to create tasks
# --------------------------------------------------------

# Use dualstack url to support ipv6
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/ecr-requests.html
locals {

  # output from container-registry stack
  registry_outputs = data.terraform_remote_state.container_registry_stack.outputs

  # ecr image endpoint with ipv6 support
  dualstack_endpoint = "${local.registry_outputs.registry_id}.dkr-ecr.${local.registry_outputs.repo_region}.on.aws/${local.registry_outputs.repo_name}"

  # tag of latest image
  tag = var.docker_image_version
}

resource "aws_ecs_task_definition" "task_def" {
  family = "tf_play_6_service" # unique name for this task def

  network_mode = "awsvpc"

  # This role is assumed by ECS Agent, installed on EC2
  # it needs permission to pull images from ecr and other things like logging
  execution_role_arn = aws_iam_role.task_def_execution.arn

  # Our containers / application code would use this role
  task_role_arn = aws_iam_role.task.arn


  container_definitions = jsonencode([
    {
      name      = "tf_play_6_hello_world"
      image     = "${local.dualstack_endpoint}:${local.tag}"
      essential = true
      memory    = 300 # MB
      cpu       = 256 # 1vCPU = 1024 units
      healthCheck = {
        command = [
          "CMD-SHELL",
          "wget -q --spider http://localhost:3000/ || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region = "us-east-1"
          awslogs-group  = "${aws_cloudwatch_log_group.ecs_log_group.name}"
        }
      }
      portMappings = [
        {
          containerPort = 3000
          # Since we're using awsvpc network mode
          # where each running container (task)
          # gets its own network interface (ENI)
          # the host port needs to be 3000 too
          hostPort = 3000
        }
      ]
    }
  ])
}


# --------------------------------------------------------
# ECS Capacity Provider - backed by ec2 auto scaling group
# --------------------------------------------------------
resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "tf_play_6_capacity_provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.asg.arn
    managed_draining       = "ENABLED"
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 80
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_provider_association" {
  cluster_name       = "tf_play_6_cluster"
  capacity_providers = ["tf_play_6_capacity_provider"]
  depends_on         = [aws_ecs_capacity_provider.capacity_provider]
}