locals {
  assign_public_ip           = var.assign_public_ip
  capacity_provider          = var.capacity_provider
  cluster_id                 = var.cluster_id
  cpu                        = var.capacity_provider == "EC2" ? null : var.cpu
  data_volume_name           = local.name
  efs_id                     = var.efs_id
  elasticsearch_java_mem     = var.elasticsearch_java_mem
  img                        = var.elasticsearch_img
  instances                  = var.instances
  memory                     = var.memory
  name                       = var.name
  network_mode               = var.network_mode
  placement_strategies       = var.capacity_provider == "EC2" ? var.placement_strategies : {}
  port                       = var.port
  requires_compatibilities   = var.requires_compatibilities
  security_group_id          = var.security_group_id
  service_discovery_dns_type = var.service_discovery_dns_type
  service_discovery_id       = var.service_discovery_id
  subnets                    = var.subnets
  tags                       = var.tags
  template_path              = "${path.module}/task-definition/elasticsearch.json.tpl"
  vpc_id                     = var.vpc_id

  task_config = {
    container_port   = local.port
    data_volume_name = local.data_volume_name
    img              = local.img
    log_group_name   = aws_cloudwatch_log_group.this.name
    memory           = local.elasticsearch_java_mem
    network_mode     = local.network_mode
    name             = local.name
    region           = data.aws_region.current.name
  }
}
