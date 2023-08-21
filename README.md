# CSpace Terraform module

Terraform module to deploy [CSpace](https://cspace.lyrasis.org/) as [AWS ECS](https://aws.amazon.com/ecs/) services.

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
  host                    = "example.collectionspace.org"
  img                     = var.backend_img
  listener_arn            = var.listener_arn
  name                    = "cspace-demo"
  routes                  = var.routes
  security_group_id       = data.aws_security_group.selected.id
  sns_topic_arn           = var.sns_topic_arn
  subnets                 = var.subnets
  tags                    = {}
  testing                 = var.testing
  timezone                = "America/New_York"
  vpc_id                  = var.vpc_id
  zone                    = "collectionspace.org"
  zone_alias              = "dev"
}

```

Given this example, the CollectionSpace core profile (if enabled) would be available at:

- `https://core.test.collectionspace.org`

`host`: An additional hostname that the load balancer will forward to the application.
`testing`: When `true`, will prefix the zone with `test.`, e.g., `core.collectionspace.org` becomes `core.test.collectionspace.org` when `testing = true`.
`zone`: The base TLD under which this instance will be deployed.
`zone_alias`: An optional subdomain that the load balancer will forward to the application.

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
