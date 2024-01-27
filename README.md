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
  path_override           = null
  profiles                = ["anthro", "bonsai", "core", "fcart",
                            "herbarium", "lhmc", "materials", "publicart"]
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

### Outputs

`hostnames`: A list of hostnames that should be used to generate DNS records.

### Understanding `profiles`

This module generates load balancer routes and hostnames off of `profiles`.
There are two distinct code paths depending on how the `profiles` variable is
set, so it's important to know the difference.

#### Single-tenant (`name != zone_alias`)

In this case, the list of `profiles` has a single value, e.g., `["anthro"]`.
This will be the case for most clients. When there is only one value in
`profiles`, the `name` and `zone_alias` are used for routing and as the
generated hostname.

Example:

```hcl
module "backend" {
  ...
  name       = "westerville"
  profiles   = ["lhmc"]
  zone_alias = "staging"
}
```

This generates a route using the name
`westerville.staging.collectionspace.org` with a path of
`/cspace/westerville/login`.

##### `path_override`

The `path_override` variable provides a way to let clients (primarily legacy)
use a different name than their hostname. An example is Ohio History Connection,
which uses `ohiohistory.collectionspace.org` but the tenant name `ohc`, so their
expected login page would be located at
`https://ohiohistory.collectionspace.org/cspace/ohc/login`

The other client in this situation is the National Videogame Museum with a
hostname of `nationalvideogamemuseum` and a tenant name of `thenvm`.

#### Multi-tenant (`name == zone_alias`)

In this case, there are multiple `profiles` in the list. This is typically only
the case for CollectionSpace Program Team instances (e.g., dev, qa, demo) where
multiple profiles are deployed for testing or demonstration purposes. When
there are multiple `profiles` specified, the `profiles` and `zone_alias` are
used for both routing and hostnames.

Example:

```hcl
module "backend" {
  ...
  name       = "dev"
  profiles   = ["anthro", "bonsai", "core", "fcart",
                "herbarium", "lhmc", "materials", "publicart"]
  zone_alias = "dev"
}
```

This generates multiple routes using the following hostnames:

* `anthro.dev.collectionspace.org` => `/cspace/anthro/login`
* `bonsai.dev.collectionspace.org` => `/cspace/bonsai/login`
* `core.dev.collectionspace.org` => `/cspace/core/login`
* `fcart.dev.collectionspace.org` => `/cspace/fcart/login`
* `herbarium.dev.collectionspace.org` => `/cspace/herbarium/login`
* `lhmc.dev.collectionspace.org` => `/cspace/lhmc/login`
* `materials.dev.collectionspace.org` => `/cspace/materials/login`
* `publicart.dev.collectionspace.org` => `/cspace/publicart/login`

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
