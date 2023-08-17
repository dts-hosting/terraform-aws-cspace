data "aws_region" "current" {}

variable "assign_public_ip" {
  default = false
}

variable "bastion_arn" {
  description = "Bastion instance ARN"
}

variable "capacity_provider" {
  default = "FARGATE"
}

variable "cluster_id" {
  description = "ECS cluster id"
}

variable "collectionspace_memory_mb" {
  default = 2048
}

variable "container_port" {
  description = "CollectionSpace service port"
  default     = 8180
}

variable "cpu" {
  default = 1024
}

variable "create_db" {
  default = true
}

variable "cspace_ui_build" {
  default = false
}

variable "custom_env_cfg" {
  default     = {}
  description = "General environment name/value configuration"
}

variable "custom_secrets_cfg" {
  default     = {}
  description = "General secrets name/value configuration"
}

variable "database_low_ram_threshold" {
  default     = 1073741824 # 1GB
  description = "RDS freeable memory threshold"
}

variable "db_id" {
  description = "Database instance ID"
}

variable "efs_id" {
  description = "EFS id"
}

variable "efs_name" {
  description = "EFS name"
}

variable "elasticsearch_memory_mb" {
  default = 1024
}

variable "health_check_attempts" {
  default = 10
}

variable "health_check_interval" {
  default = 60
}

variable "health_check_path" {
  default = "/cspace-services/systeminfo"
}

variable "host" {
  description = "CSpace backend host"
}

variable "img" {
  description = "CSpace backend docker img"
}

variable "instances" {
  default = 1
}

variable "listener_arn" {
  description = "ALB (https) listener arn"
}

variable "listener_priority" {
  description = "ALB (https) listener priority"
}

variable "name" {
  description = "AWS ECS resources name/alias (service name, task definition name etc.)"
}

variable "network_mode" {
  default = "awsvpc"
}

variable "port" {
  description = "CSpace backend port"
  default     = 8080
}

variable "requires_compatibilities" {
  default = ["FARGATE"]
}

variable "routes" {
  description = "List of CSpace routes"
}

variable "security_group_id" {
  description = "Security group id"
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

variable "subnets" {
  description = "Subnets"
}

variable "tags" {
  default = {}
}

variable "target_type" {
  default = "ip"
}

variable "tasks" {
  description = "Tasks to run on schedule: { name = {args, schedule} }"
  default     = {}
}

variable "testing" {
  description = "Whether this deployment is for testing (adds .test to the hostname)"
  default     = false
}

variable "timezone" {
  description = "Timezone"
}

variable "vpc_id" {
  description = "VPC id"
}

variable "zone" {
  description = "Zone"
}

variable "zone_alias" {
  description = "Zone alias"
}
