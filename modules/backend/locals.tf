locals {
  assign_public_ip          = var.assign_public_ip
  backend_name              = local.resource_prefix
  capacity_provider         = var.capacity_provider
  cluster_id                = var.cluster_id
  collectionspace_memory_mb = var.collectionspace_memory_mb
  container_port            = var.container_port
  cpu                       = local.capacity_provider == "EC2" ? null : var.cpu
  create_db                 = var.create_db
  cspace_memory             = var.collectionspace_memory_mb
  cspace_ui_build           = var.cspace_ui_build
  efs_id                    = var.efs_id
  elasticsearch_enabled     = var.elasticsearch_enabled
  elasticsearch_memory_mb   = local.elasticsearch_enabled ? var.elasticsearch_memory_mb : 0
  elasticsearch_url         = var.elasticsearch_url
  env_cluster_name          = split("/", var.cluster_id)[1]
  extra_hosts               = var.extra_hosts
  full_hostname             = "${coalesce(local.subdomain_override, local.name)}.${local.host_with_alias}"
  health_check_attempts     = var.health_check_attempts
  health_check_interval     = var.health_check_interval
  health_check_path         = var.health_check_path
  hostnames = length(local.profiles) == 1 ? [local.full_hostname] : [
    for profile in local.profiles : "${profile}.${local.host_with_alias}"
  ]
  host_headers             = concat([local.full_hostname], local.extra_hosts)
  host_with_alias          = length(local.zone_alias) > 0 ? "${local.zone_alias}.${local.zone}" : local.zone
  img                      = var.img
  img_tag                  = split(":", var.img)[1]
  img_repository           = regex("/(.*):", var.img)[0]
  instance_count           = var.instances
  listener_arn             = var.listener_arn
  name                     = var.name
  pathname_override        = var.pathname_override
  placement_strategies     = local.capacity_provider == "EC2" ? var.placement_strategies : {}
  profiles                 = var.profiles
  requires_compatibilities = var.requires_compatibilities
  resource_prefix          = (length(local.zone_alias) == 0 || local.name == local.zone_alias) ? local.name : "${local.name}${local.zone_alias}"
  route_prefix             = (length(local.zone_alias) == 0 || local.name == local.zone_alias) ? local.name : "${local.name}.${local.zone_alias}"
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
  security_group_id     = var.security_group_id
  sns_topic_arn         = var.sns_topic_arn
  subdomain_override    = var.subdomain_override
  subnets               = var.subnets
  swap_size             = 1024
  tags                  = var.tags
  task_memory_buffer_mb = var.task_memory_buffer_mb
  task_memory_mb = max(
    var.task_memory_mb,
    local.collectionspace_memory_mb + local.elasticsearch_memory_mb + local.task_memory_buffer_mb
  )
  template_path = join("", ["${path.module}/task-definition/", local.elasticsearch_enabled ? "app-plus-es.json.tpl" : "app-without-es.json.tpl"])
  timezone      = var.timezone
  vpc_id        = var.vpc_id
  zone          = var.zone
  zone_alias    = var.zone_alias
}
