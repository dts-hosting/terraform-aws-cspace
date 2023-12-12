# CSpace Terraform module

Terraform module to deploy [CSpace](https://cspace.lyrasis.org/) as [AWS ECS](https://aws.amazon.com/ecs/) services.

This module creates a trigger on `PutImage` that causes the associated ECS service to restart when CodeBuild has completed.

- [General infrastructure requirements](REQS.md)

## Examples

- [Using pre-existing resources example as inputs to CSpace module](examples/services)

## Usage

### Backend

Run the CollectionSpace backend (REST API server).

Module configuration

```hcl
module "backend" {
  source = "github.com/dts-hosting/terraform-aws-cspace/modules/backend"

  cluster_id              = var.cluster_id
  container_port          = var.container_port
  efs_id                  = var.efs_id
  img                     = var.backend_img
  listener_arn            = var.listener_arn
  name                    = "cspace-demo"
  routes                  = var.routes
  security_group_id       = data.aws_security_group.selected.id
  sns_topic_arn           = var.sns_topic_arn
  subnets                 = var.subnets
  tags                    = {}
  timezone                = "America/New_York"
  vpc_id                  = var.vpc_id
  zone                    = "collectionspace.org"
  zone_alias              = "dev"
}

```

Given this example, the CollectionSpace core profile would be available at:

- `https://core.dev.collectionspace.org`

`zone`: The base TLD under which this instance will be deployed.  
`zone_alias`: An optional subdomain prefix that the load balancer will forward to the application.
Used for multi-tenant cases, e.g., `dev` or `qa` so that sites are, e.g., `core.dev` or `anthro.dev`.

For all configuration options review the [variables file](modules/backend/variables.tf).

## Launch type configuration

The `backend` module can deploy to either EC2 or Fargate.

> ⚠️ **WARNING** When using EC2, you must use instance types that support "awsvpc" networking.

To deploy to an ECS/EC2 auto-scaling group:

```ini
capacity_provider        = "EC2"
requires_compatibilities = ["EC2"]
target_type              = "instance"
```

## Memory configuration

Each ECS task definition has tasks with separate memory allocations so that the
memory available to each task may be set independently.

`collectionspace_memory_mb`: The MB of memory to allocate for the
CollectionSpace task. (Default: `2048`)  
`elasticsearch_memory_mb`: The MB of memory to allocate for the ElasticSearch
task. (Default: `1024`)  
`task_memory_buffer_mb`: The MB of memory that should be available in excess of
the specific allocation for tasks.
`collectionspace_memory_mb + elasticsearch_memory_mb`. (Default: `512`)  
`task_memory_mb`: The total MB (hard limit) within which the containers need
to run.  

The value passed to the module for `task_memory_mb` will be the greater of:

`task_memory_mb` and `collectionspace_memory_mb + elasticsearch_memory_mb + task_memory_buffer_mb`
