locals {
  assign_public_ip          = var.assign_public_ip
  backend_name              = "${var.name}-backend"
  capacity_provider         = var.capacity_provider
  cluster_id                = var.cluster_id
  collectionspace_memory_mb = var.collectionspace_memory_mb
  container_port            = var.container_port
  cpu                       = local.capacity_provider == "EC2" ? null : var.cpu
  create_db                 = var.create_db
  cspace_memory             = var.collectionspace_memory_mb
  cspace_ui_build           = var.cspace_ui_build
  efs_id                    = var.efs_id
  elasticsearch_memory_mb   = var.elasticsearch_memory_mb
  env_cluster_name          = split("/", var.cluster_id)[1]
  es_efs_name               = "${var.name}-es-data"
  health_check_attempts     = var.health_check_attempts
  health_check_interval     = var.health_check_interval
  health_check_path         = var.health_check_path
  host                      = var.host
  host_headers              = distinct([local.host_with_alias, local.host_with_site])
  host_with_alias           = length(local.zone_alias) > 0 ? "${local.zone_alias}.${local.host}" : local.host_with_site
  host_with_site            = "${local.name}.${local.host}"
  hostzone                  = var.testing ? "test.${var.zone}" : var.zone
  img                       = var.img
  img_tag                   = split(":", var.img)[1]
  img_repository            = regex("/(.*):", var.img)[0]
  instance_count            = var.instances
  listener_arn              = var.listener_arn
  name                      = var.name
  placement_strategies      = var.placement_strategies
  requires_compatibilities  = var.requires_compatibilities
  routes                    = var.routes
  security_group_id         = var.security_group_id
  sns_topic_arn             = var.sns_topic_arn
  subnets                   = var.subnets
  tags                      = var.tags
  task_memory_buffer_mb     = var.task_memory_buffer_mb
  task_memory_mb = max(
    var.task_memory_mb,
    local.collectionspace_memory_mb + local.elasticsearch_memory_mb + local.task_memory_buffer_mb
  )
  template_path = "${path.module}/task-definition/app.json.tpl"
  timezone      = var.timezone
  vpc_id        = var.vpc_id
  zone          = var.zone
  zone_alias    = var.zone_alias
}
