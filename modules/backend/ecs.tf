resource "aws_ecs_task_definition" "this" {
  family                   = local.backend_name
  network_mode             = "awsvpc"
  requires_compatibilities = local.requires_compatibilities
  cpu                      = local.cpu
  memory                   = local.task_memory_mb
  execution_role_arn       = local.iam_ecs_task_role_arn
  task_role_arn            = local.iam_ecs_task_role_arn
  container_definitions = templatefile(local.template_path, {
    capacity_provider = local.capacity_provider
    container_port    = local.container_port
    cpu               = local.cpu
    create_db         = local.create_db
    cspace_memory     = local.collectionspace_memory_mb
    cspace_ui_build   = local.cspace_ui_build
    elasticsearch_url = local.elasticsearch_url
    img               = local.img
    log_group_name    = aws_cloudwatch_log_group.this.name
    name              = local.backend_name
    region            = data.aws_region.current.name
    swap_size         = local.swap_size
    timezone          = local.timezone
  })
}

resource "aws_ecs_service" "this" {
  name            = local.backend_name
  cluster         = local.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = local.instance_count

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  enable_execute_command = true

  capacity_provider_strategy {
    capacity_provider = local.capacity_provider
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "app"
    container_port   = local.container_port
  }

  network_configuration {
    assign_public_ip = local.assign_public_ip
    security_groups  = [local.security_group_id]
    subnets          = local.subnets
  }

  dynamic "ordered_placement_strategy" {
    for_each = local.placement_strategies
    content {
      field = ordered_placement_strategy.value.field
      type  = ordered_placement_strategy.value.type
    }
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${local.backend_name}"
  retention_in_days = 7
}
