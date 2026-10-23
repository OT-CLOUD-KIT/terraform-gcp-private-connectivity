
output "private_service_access_range_name" {
  description = "Name of the reserved PSA IP range, if created."
  value       = try(google_compute_global_address.private_service_access[0].name, null)
}

output "private_service_access_connection" {
  description = "PSA connection details, if created."
  value       = try(google_service_networking_connection.private_service_access[0].peering, null)
}

output "psc_endpoint_ips" {
  description = "Reserved internal IP addresses for PSC endpoints."
  value = {
    for name, address in google_compute_address.psc :
    name => address.address
  }
}

output "psc_forwarding_rule_names" {
  description = "Names of PSC endpoint forwarding rules."
  value = {
    for name, rule in google_compute_forwarding_rule.psc :
    name => rule.name
  }
}

output "pga_subnet_names" {
  description = "Names of subnets created with Private Google Access enabled."
  value = {
    for name, subnet in google_compute_subnetwork.pga :
    name => subnet.name
  }
}

output "pga_subnet_self_links" {
  description = "Self-links of the Private Google Access subnets."
  value = {
    for name, subnet in google_compute_subnetwork.pga :
    name => subnet.self_link
  }
}
