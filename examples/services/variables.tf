variable "backend_img" {
  default = "collectionspace/collectionspace:latest"
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

variable "elasticsearch_img" {
  default = "elasticsearch:5.6.12"
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
variable "dns_zone_name" { default = "collectionspace.org" }
variable "department" {}
variable "environment" {}
variable "project_account_id" {}
variable "region" { default = "us-west-2" }
variable "role" {}
variable "service" {}
### module
variable "cluster_name" {}
variable "lb_name" {}
variable "pathname_override" { default = null }
variable "profiles" { default = ["anthro", "bonsai", "core", "fcart", "herbarium", "lhmc", "materials", "publicart"] }
variable "security_group_name" {}
variable "sns_topic_name" {}
variable "subnet_type" {}
variable "vpc_name" {}
### ES
variable "elasticsearch_discovery_namespace" { default = "cspace.elasticsearch" }
variable "efs_name" {}

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

data "aws_security_group" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.security_group_name]
  }
}

data "aws_service_discovery_dns_namespace" "selected" {
  name = var.elasticsearch_discovery_namespace
  type = "DNS_PRIVATE"
}

data "aws_sns_topic" "selected" {
  name = var.sns_topic_name
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
