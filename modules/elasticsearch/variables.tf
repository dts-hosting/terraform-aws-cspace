data "aws_region" "current" {}

variable "assign_public_ip" {
  description = "Assign a public IP to the ECS task"
  type        = bool
  default     = false
}

variable "capacity_provider" {
  description = "The capacity provider to use for the ECS service"
  type        = string
  default     = "FARGATE"
}

variable "cluster_id" {
  description = "The ECS cluster to use for the ECS service"
  type        = string
}

variable "cpu" {
  description = "The number of CPU units to reserve for the ECS task"
  type        = number
  default     = 512
}

variable "efs_id" {
  description = "The EFS ID to use for the ECS task"
  type        = string
}

variable "elasticsearch_img" {
  description = "The Docker image to use for the ECS task"
  type        = string
  default     = "elasticsearch:5.6.12"
}

variable "elasticsearch_java_mem" {
  description = "Container-level memory allocation (ElasticSearch)"
  type        = number
  default     = 768
}

variable "img" {
  description = "The Docker image to use for the ECS task"
  type        = string
}

variable "instances" {
  description = "The number of instances to run for the ECS service"
  type        = number
  default     = 1
}

variable "memory" {
  description = "The amount of memory to reserve for the ECS task (hard limit)"
  type        = number
  default     = 1024
}

variable "name" {
  description = "The name of the ECS service"
  type        = string
}

variable "network_mode" {
  description = "The network mode to use for the ECS task"
  type        = string
  default     = "awsvpc"
}

variable "placement_strategies" {
  description = "The placement strategies to use for the ECS service"
  type        = map(map(string))
  default = {
    "pack-by-memory" = {
      "type"  = "binpack"
      "field" = "memory"
    }
  }
}

variable "port" {
  description = "CollectionSpace ElasticSearch port"
  type        = number
  default     = 9200
}

variable "requires_compatibilities" {
  description = "The ECS task requires compatibilities"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "security_group_id" {
  description = "The security group ID to use for the ECS task"
  type        = string
}

variable "subnets" {
  description = "The subnets to use for the ECS task"
  type        = list(string)
}

variable "tags" {
  description = "The tags to apply to the ECS service"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The VPC ID to use for the ECS task"
  type        = string
}
