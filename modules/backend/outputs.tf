output "hostnames" {
  description = "The hostname(s) expected by the load balancer for the generated routes."
  value       = local.hostnames
}
