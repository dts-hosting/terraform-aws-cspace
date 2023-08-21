terraform {
  cloud {
    organization = "Lyrasis"

    workspaces {
      name = "cspace-module-services-test"
    }
  }
}

provider "aws" {
  region              = local.region
  allowed_account_ids = [var.project_account_id]

  assume_role {
    role_arn = "arn:aws:iam::${var.project_account_id}:role/${var.role}"
  }
}

provider "aws" {
  alias               = "dns"
  region              = local.region
  allowed_account_ids = [var.dns_account_id]

  assume_role {
    role_arn = "arn:aws:iam::${var.dns_account_id}:role/${var.role}"
  }
}

locals {
  name   = "cspace-ex-${basename(path.cwd)}"
  region = var.region

  vpc_cidr = "10.99.0.0/18"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/dts-hosting/terraform-aws-cspace"
  }

  zone = var.testing ? "test.${var.domain}" : var.domain
}

################################################################################
# CSpace resources
################################################################################

module "backend" {
  source = "../../modules/backend"

  cluster_id        = data.aws_ecs_cluster.selected.id
  container_port    = var.container_port
  efs_id            = data.aws_efs_file_system.selected.id
  efs_name          = var.efs_name
  host              = "${var.zone_alias}.${var.domain}"
  img               = var.backend_img
  listener_arn      = data.aws_lb_listener.selected.arn
  listener_priority = 1
  name              = local.name
  routes            = var.routes
  security_group_id = data.aws_security_group.selected.id
  sns_topic_arn     = data.aws_sns_topic.selected.arn
  subnets           = data.aws_subnets.selected.ids
  tags              = local.tags
  testing           = var.testing
  timezone          = "America/New_York"
  vpc_id            = data.aws_vpc.selected.id
  zone              = var.domain
  zone_alias        = var.zone_alias
}

################################################################################
# Supporting resources
################################################################################

resource "aws_route53_record" "this" {
  provider = aws.dns

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.zone_alias}.${var.domain}"
  type    = "A"

  alias {
    name                   = data.aws_lb.selected.dns_name
    zone_id                = data.aws_lb.selected.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "app_routes" {
  for_each = { for route in var.routes : route.name => route }

  provider = aws.dns

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${each.key}.${local.zone}"
  type    = "A"

  alias {
    name                   = data.aws_lb.selected.dns_name
    zone_id                = data.aws_lb.selected.zone_id
    evaluate_target_health = true
  }
}
