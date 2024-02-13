resource "aws_ecs_task_definition" "this" {
  family                   = local.name
  network_mode             = local.network_mode
  requires_compatibilities = local.requires_compatibilities
  cpu                      = local.cpu
  memory                   = local.memory
  execution_role_arn       = aws_iam_role.this.arn
  task_role_arn            = aws_iam_role.this.arn
  container_definitions    = templatefile(local.template_path, local.task_config)

  volume {
    name = local.data_volume_name

    efs_volume_configuration {
      file_system_id     = local.efs_id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.data.id
      }
    }
  }
}

resource "aws_ecs_service" "elasticsearch" {
  name            = local.name
  cluster         = local.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = local.instances

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  enable_execute_command = true

  capacity_provider_strategy {
    capacity_provider = local.capacity_provider
    weight            = 100
  }

  dynamic "network_configuration" {
    for_each = local.network_mode == "awsvpc" ? [1] : []

    content {
      assign_public_ip = local.assign_public_ip
      security_groups  = [local.security_group_id]
      subnets          = local.subnets
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = local.placement_strategies

    content {
      type  = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }

  depends_on = [aws_ecs_task_definition.this]

  tags = local.tags
}

resource "aws_efs_access_point" "data" {
  file_system_id = local.efs_id

  root_directory {
    path = "/${local.data_volume_name}"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${local.name}"
  retention_in_days = 7
}
