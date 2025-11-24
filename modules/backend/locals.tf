locals {
  assign_public_ip          = var.assign_public_ip
  backend_name              = local.resource_prefix
  capacity_provider         = var.capacity_provider
  cluster_id                = var.cluster_id
  codebuild_compute_type    = "BUILD_GENERAL1_MEDIUM"
  codebuild_image           = "aws/codebuild/standard:5.0"
  codebuild_input_bucket    = var.codebuild_input_bucket
  codebuild_role_name       = var.codebuild_role_name
  codebuild_type            = "LINUX_CONTAINER"
  collectionspace_memory_mb = var.collectionspace_memory_mb
  container_port            = var.container_port
  cpu                       = var.cpu
  create_db                 = var.create_db
  cspace_memory             = var.collectionspace_memory_mb
  cspace_ui_build           = var.cspace_ui_build
  elasticsearch_url         = var.elasticsearch_url
  env_cluster_name          = split("/", var.cluster_id)[1]
  extra_hosts               = var.extra_hosts
  full_hostname             = "${coalesce(local.subdomain_override, local.name)}.${local.host_with_alias}"
  health_check_attempts     = var.health_check_attempts
  health_check_interval     = var.health_check_interval
  health_check_path         = var.health_check_path
  host_headers              = concat([local.full_hostname], local.extra_hosts)
  host_with_alias           = length(local.zone_alias) > 0 ? "${local.zone_alias}.${local.zone}" : local.zone
  iam_ecs_task_role_arn     = var.iam_ecs_task_role_arn
  img                       = var.img
  img_tag                   = split(":", var.img)[1]
  img_repository            = regex("/(.*):", var.img)[0]
  instance_count            = var.instances
  listener_arn              = var.listener_arn
  name                      = var.name
  pathname_override         = var.pathname_override
  placement_strategies      = local.capacity_provider == "EC2" ? var.placement_strategies : {}
  profiles                  = var.profiles
  requires_compatibilities  = var.requires_compatibilities
  resource_prefix           = (length(local.zone_alias) == 0 || local.name == local.zone_alias) ? local.name : "${local.name}${local.zone_alias}"
  route_prefix              = (length(local.zone_alias) == 0 || local.name == local.zone_alias) ? coalesce(local.subdomain_override, local.name) : "${coalesce(local.subdomain_override, local.name)}.${local.zone_alias}"
  security_group_id         = var.security_group_id
  sns_topic_arn             = var.sns_topic_arn
  subdomain_override        = var.subdomain_override
  subnets                   = var.subnets
  swap_size                 = 1024
  tags                      = var.tags
  task_memory_buffer_mb     = var.task_memory_buffer_mb
  template_path             = "${path.module}/task-definition/app.json.tpl"
  timezone                  = var.timezone
  vpc_id                    = var.vpc_id
  zone                      = var.zone
  zone_alias                = var.zone_alias

  # derive hostnames from profiles (used as outputs for creating dns records)
  hostnames = length(local.profiles) == 1 ? [local.full_hostname] : [
    for profile in local.profiles : "${profile}.${local.host_with_alias}"
  ]

  # derive routes from profiles (used to create listener rules)
  routes = length(local.profiles) == 1 ? [{
    name = local.route_prefix
    host = local.full_hostname
    path = "/cspace/${coalesce(local.pathname_override, local.name)}/login"
    }] : [
    for profile in local.profiles : {
      name = length(local.zone_alias) > 0 ? "${profile}.${local.zone_alias}" : profile
      host = "${profile}.${local.host_with_alias}"
      path = "/cspace/${profile}/login"
    }
  ]

  # determine memory (task definition hard limit)
  task_memory_mb = max(
    var.task_memory_mb,
    local.collectionspace_memory_mb + local.task_memory_buffer_mb
  )
}
