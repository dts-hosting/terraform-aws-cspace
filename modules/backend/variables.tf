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

variable "efs_id" {
  description = "EFS id"
}

variable "elasticsearch_memory_mb" {
  default = 1024
}

variable "extra_hosts" {
  description = "Additional hosts for routing via host header condition"
  default     = []
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

variable "img" {
  description = "CSpace backend docker img"
}

variable "instances" {
  default = 1
}

variable "listener_arn" {
  description = "ALB (https) listener arn"
}

variable "name" {
  description = "AWS ECS resources name/alias (service name, task definition name etc.)"
}

variable "network_mode" {
  default = "awsvpc"
}

variable "placement_strategies" {
  default = {
    pack-by-memory = {
      field = "memory"
      type  = "binpack"
    }
  }
}

variable "port" {
  description = "CSpace backend port"
  default     = 8080
}

variable "profiles" {
  description = "List of profiles to support"
  default     = []
}

variable "requires_compatibilities" {
  default = ["FARGATE"]
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

variable "task_memory_buffer_mb" {
  description = "Available task memory in excess of CSpace + ES"
  default     = 512
}

variable "task_memory_mb" {
  description = "Memory allocation for task (hard limit)"
  default     = 3072
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
  default     = ""
  description = "Zone alias (a.k.a. subdomain, e.g., 'dev' for dev.collectionspace.org)"
}
