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

  profiles = var.profiles
  zone     = var.domain
}

################################################################################
# CSpace resources
################################################################################

module "backend" {
  source = "../../modules/backend"

  cluster_id        = data.aws_ecs_cluster.selected.id
  container_port    = var.container_port
  efs_id            = data.aws_efs_file_system.selected.id
  img               = var.backend_img
  listener_arn      = data.aws_lb_listener.selected.arn
  name              = local.name
  profiles          = local.profiles
  security_group_id = data.aws_security_group.selected.id
  sns_topic_arn     = data.aws_sns_topic.selected.arn
  subnets           = data.aws_subnets.selected.ids
  tags              = local.tags
  timezone          = "America/New_York"
  vpc_id            = data.aws_vpc.selected.id
  zone              = var.domain
  zone_alias        = var.zone_alias
}
