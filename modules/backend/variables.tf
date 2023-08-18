data "aws_region" "current" {}

variable "assign_public_ip" {
  default = false
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

variable "log_filter_patterns" {
  description = "Map of log filter name => pattern, description objects"
  default = {
    "nuxeo-session" = {
      comparison_operator = "GreaterThanOrEqualToThreshold"
      datapoints_to_alarm = 1
      description         = "CSpace nuxeo session (db connection) alarm"
      evaluation_periods  = 1
      pattern             = "Could not open a session to the Nuxeo repository"
      period              = 300
      statistic           = "Sum"
      threshold           = "1000"
    }
  }
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

variable "sns_topic_arn" {
  description = "SNS topic ARN"
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
