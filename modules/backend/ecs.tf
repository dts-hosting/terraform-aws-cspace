locals {
  backend_name = "${var.name}-backend"
  es_efs_name  = "${var.name}-es-data"
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.backend_name
  network_mode             = "awsvpc"
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.task_memory_mb
  execution_role_arn       = aws_iam_role.this.arn
  task_role_arn            = aws_iam_role.this.arn
  container_definitions = templatefile("${path.module}/task-definition/app.json.tpl", {
    container_port       = var.container_port
    create_db            = var.create_db
    cspace_memory        = var.collectionspace_memory_mb
    cspace_ui_build      = var.cspace_ui_build
    es_efs_name          = local.es_efs_name
    elasticsearch_memory = var.elasticsearch_memory_mb
    img                  = var.img
    log_group_name       = aws_cloudwatch_log_group.this.name
    region               = data.aws_region.current.name
    timezone             = var.timezone
  })

  volume {
    name = local.es_efs_name

    efs_volume_configuration {
      file_system_id     = var.efs_id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.es.id
      }
    }
  }
}

resource "aws_ecs_service" "this" {
  name            = local.backend_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.instances

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  enable_execute_command = true

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "app"
    container_port   = var.container_port
  }

  network_configuration {
    assign_public_ip = var.assign_public_ip
    security_groups  = [var.security_group_id]
    subnets          = var.subnets
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_efs_access_point" "es" {
  file_system_id = var.efs_id

  root_directory {
    path = "/${local.es_efs_name}"
    creation_info {
      owner_gid   = 1001
      owner_uid   = 1001
      permissions = "755"
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${local.backend_name}"
  retention_in_days = 7

  tags = var.tags
}
