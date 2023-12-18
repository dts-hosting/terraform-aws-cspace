output "hostnames" {
  description = "The hostname(s) expected by the load balancer for the generated routes."
  value       = local.hostnames
}

# Debugging purposes
output "full_hostname" {
  value = local.full_hostname
}

output "host_with_alias" {
  value = local.host_with_alias
}

output "manual_host_with_alias" {
  value = local.is_zone_alias ? "${local.zone_alias}.${local.zone}" : local.zone
}
