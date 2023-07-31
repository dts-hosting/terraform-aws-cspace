variable "backend_img" {
    default = ""
}

variable "certificate_domain" {
    default = "*.collectionspace.org"
}

variable "container_port" {
  default = 8180
}

variable "create_db" {
  default = true
}

variable "cspace_ui_build" {
  default = false
}

variable "domain" {
    default = "collectionspace.org"
}

variable "log_group_name" {
  default = "/aws/ecs/cspace"
}

variable "profile" {
    default = "collectionspace"
}

variable "profile_for_dns" {
    default = "default"
}

variable "routes" {
    description = "Routes for CSpace ALB"
    default = [
        {
            name = "anthro"
            host = "anthro.collectionspace.org"
            path = "/cspace/anthro/login"
        },
        {
            name = "bonsai"
            host = "bonsai.collectionspace.org"
            path = "/cspace/bonsai/login"
        },
        {
            name = "botgarden"
            host = "botgarden.collectionspace.org"
            path = "/cspace/botgarden/login"
        },
        {
            name = "core"
            host = "core.collectionspace.org"
            path = "/cspace/core/login"
        },
        {
            name = "fcart"
            host = "fcart.collectionspace.org"
            path = "/cspace/fcart/login"
        },
        {
            name = "herbarium"
            host = "herbarium.collectionspace.org"
            path = "/cspace/herbarium/login"
        },
        {
            name = "lhmc"
            host = "lhmc.collectionspace.org"
            path = "/cspace/lhmc/login"
        },
        {
            name = "materials"
            host = "materials.collectionspace.org"
            path = "/cspace/materials/login"
        },
        {
            name = "publicart"
            host = "publicart.collectionspace.org"
            path = "/cspace/publicart/login"
        },
    ]
}

variable "zone_alias" {
  default = "dev"
}

provider "aws" {
    region = local.region
    profile = var.profile
}

provider "aws" {
  region  = local.region
  profile = var.profile_for_dns
  alias   = "dns"
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_acm_certificate" "issued" {
  domain   = var.certificate_domain
  statuses = ["ISSUED"]
}
data "aws_route53_zone" "selected" {
  provider = aws.dns
  name     = "${var.domain}."
}

locals {
  name   = "cspace-ex-${basename(path.cwd)}"
  region = "us-west-2"

  vpc_cidr = "10.99.0.0/18"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/dts-hosting/terraform-aws-cspace"
  }
}

################################################################################
# CSpace resources
################################################################################

module "backend" {
  source = "../../modules/backend"

  cluster_id        = module.ecs.cluster_id
  container_port    = var.container_port
  efs_id            = module.efs.id
  host              = "${local.name}.${var.domain}"
  img               = var.backend_img
  listener_arn      = module.alb.https_listener_arns[0]
  listener_priority = 1
  log_group_name    = var.log_group_name
  name              = "${local.name}-backend"
  routes            = var.routes
  s3_storage_key_param = var.s3_storage_key_param
  s3_storage_secret_param = var.s3_storage_secret_param
  security_group_id = module.cspace_sg.security_group_id
  subnets           = module.vpc.private_subnets
  tags              = local.tags
  timezone          = "America/New_York"
  vpc_id            = module.vpc.vpc_id
  zone              = var.domain
  zone_alias        = var.zone_alias
}

################################################################################
# Supporting resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]

  create_database_subnet_group = true
  enable_dns_hostnames         = true
  enable_dns_support           = true
  enable_nat_gateway           = true
  map_public_ip_on_launch      = false
  single_nat_gateway           = true

  tags = local.tags
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-alb"
  description = "ALB security group"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = local.tags
}

module "cspace_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-cspace"
  description = "CSpace services example security group"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      description = "EFS access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "CSpace backend access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = local.tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name               = local.name
  load_balancer_type = "application"

  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.public_subnets
  security_groups       = [module.alb_sg.security_group_id]
  create_security_group = false

  # Fixed responses for default actions
  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"

      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  ]

  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = data.aws_acm_certificate.issued.arn
      action_type     = "fixed-response"

      fixed_response = {
        content_type = "text/plain"
        message_body = "Nothing to see here!"
        status_code  = "200"
      }
    },
  ]

  tags = local.tags
}

module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "~> 1.0"

  # File system
  name      = local.name
  encrypted = true

  lifecycle_policy = {
    transition_to_ia                    = "AFTER_30_DAYS"
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  # File system policy
  attach_policy                      = true
  bypass_policy_lockout_safety_check = false
  deny_nonsecure_transport           = false

  policy_statements = [
    {
      sid     = "ClientMount"
      actions = ["elasticfilesystem:ClientMount"]
      principals = [
        {
          type        = "AWS"
          identifiers = ["*"]
        }
      ]
    },
    {
      sid     = "ClientRootAccess"
      actions = ["elasticfilesystem:ClientRootAccess"]
      principals = [
        {
          type        = "AWS"
          identifiers = ["*"]
        }
      ]
    },
    {
      sid     = "ClientWrite"
      actions = ["elasticfilesystem:ClientWrite"]
      principals = [
        {
          type        = "AWS"
          identifiers = ["*"]
        }
      ]
    }
  ]

  # Mount targets / security group
  mount_targets              = { for k, v in zipmap(local.azs, module.vpc.private_subnets) : k => { subnet_id = v } }
  security_group_description = "EFS security group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_rules = {
    vpc = {
      description = "NFS ingress from VPC"
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  tags = local.tags
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 4.0"

  cluster_name = local.name

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = var.log_group_name
      }
    }
  }

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = local.tags
}

resource "aws_route53_record" "this" {
  provider = aws.dns

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${local.name}.${var.domain}"
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "app_routes" {
  for_each = { for route in var.routes : route.name => route }

  provider = aws.dns

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${each.key}.${var.domain}"
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

################################################################################
# External resources
################################################################################
variable "s3_storage_key_param" {}
variable "s3_storage_secret_param" {}
