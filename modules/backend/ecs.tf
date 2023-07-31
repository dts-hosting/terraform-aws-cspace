locals {
  name = var.name
  searchstore_volume = "${var.name}-searchstore"
  total_memory = var.collectionspace_memory_mb + var.elasticsearch_memory_mb
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = local.total_memory
  execution_role_arn       = aws_iam_role.this.arn
  task_role_arn            = aws_iam_role.this.arn
  container_definitions    = templatefile("${path.module}/task-definition/app.json.tpl", {
    aws_storage_key        = data.aws_ssm_parameter.storage_key.value
    aws_storage_secret_key = data.aws_ssm_parameter.storage_secret.value
    container_port         = var.container_port
    cpu                    = var.cpu
    create_db              = var.create_db
    cspace_ui_build        = var.cspace_ui_build
    elasticsearch_memory   = var.elasticsearch_memory_mb
    img                    = var.img
    log_group_name         = var.log_group_name
    region                 = data.aws_region.current.name
    s3_storage_bucket      = var.s3_storage_bucket
    searchstore            = local.searchstore_volume
    total_memory           = local.total_memory
  })

  volume {
    name = local.searchstore_volume

    efs_volume_configuration {
      file_system_id = var.efs_id
      transit_encryption = "ENABLED"
      
      authorization_config {
        access_point_id = aws_efs_access_point.this.id
      }
    }
  }
}

resource "aws_ecs_service" "this" {
  name            = var.name
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
    assign_public_ip = true
    security_groups  = [var.security_group_id]
    subnets          = var.subnets
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_efs_access_point" "this" {
  file_system_id = var.efs_id

  root_directory {
    path = "/${local.searchstore_volume}"
    creation_info {
      owner_gid   = 1001
      owner_uid   = 1001
      permissions = "755"
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${local.name}"
  retention_in_days = 7

  tags = var.tags
}
