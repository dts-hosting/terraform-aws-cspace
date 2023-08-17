variable "backend_img" {
  default = "collectionspace/collectionspace:latest"
}

variable "bastion_name" {
  default = "bastion"
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

variable "slack_webhook_url" {
  description = "Slack webhook URL"
}

variable "slack_channel" {
  description = "Slack channel"
}

variable "slack_username" {
  description = "Slack username"
}

variable "testing" {
  default = true
}

variable "zone_alias" {
  default = "test"
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_route53_zone" "selected" {
  provider = aws.dns
  name     = "${var.domain}."
}

################################################################################
# External resources
################################################################################
variable "dns_account_id" {}
variable "dns_zone_name" {}
variable "department" {}
variable "environment" {}
variable "project_account_id" {}
variable "region" { default = "us-west-2" }
variable "role" {}
variable "service" {}
### module
variable "cluster_name" {}
variable "db_name" {}
variable "efs_name" {}
variable "lb_name" {}
variable "security_group_name" {}
variable "subnet_type" {}
variable "vpc_name" {}

data "aws_ecs_cluster" "selected" {
  cluster_name = var.cluster_name
}

data "aws_efs_file_system" "selected" {
  tags = {
    Name = var.efs_name
  }
}

data "aws_lb" "selected" {
  name = var.lb_name
}

data "aws_lb_listener" "selected" {
  load_balancer_arn = data.aws_lb.selected.arn
  port              = 443
}

data "aws_db_instance" "selected" {
  db_instance_identifier = var.db_name
}

data "aws_instance" "bastion" {
  filter {
    name   = "tag:Name"
    values = [var.bastion_name]
  }
}

data "aws_security_group" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.security_group_name]
  }
}

data "aws_subnets" "selected" {
  filter {
    name   = "tag:Type"
    values = [var.subnet_type]
  }
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}
