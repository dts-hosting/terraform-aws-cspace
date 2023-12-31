## Important

This module assumes that infrastructure will be run in "awsvpc" networking
mode. It does not support "host" or "bridge" network modes. If using EC2 as
a capacity provider, the instance types must support "awsvpc".

# General infrastructure requirements

As a group the module requires (but does not create):

- A VPC
- 2+ subnets within the VPC (public & private recommended)
- 1+ security group/s that allow ingress from outside the VPC
- 1+ security group/s that allow ingress from within the VPC
- An application load balancer assigned to public subnets in the VPC
- EFS storage for persistent data permitting access from within the VPC
- ECS cluster / autoscaling group (latter optional if using Fargate)
- Postgres database (RDS or other) connection details
- DNS records (Route53 or other) for publicly accessible CSpace services

These resources can be created however you like and are broadly outlined
as implementation details can vary (such as whether to use public vs.
private subnets with a NAT gateway; the specifics of how security groups
are defined, and so on). There are many, many viable ways to do it.

Resources that are "modified" by one or more of the CSpace modules are:

- EFS: access points are created
- Load balancer: listener rules are created

Therefore it is recommended that these resources be considered "dedicated"
to CSpace or that care is taken to ensure that mixed-usage does not lead to
unintended conflicts.

The example project shows a way that externally created resources can be
used with this module.
