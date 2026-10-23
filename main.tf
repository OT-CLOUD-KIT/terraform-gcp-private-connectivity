# --- Private Service Access (PSA) ---

resource "google_compute_global_address" "private_service_access" {
  count = var.private_service_access == null ? 0 : 1

  project       = var.project_id
  name          = var.private_service_access.name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.private_service_access.address
  prefix_length = var.private_service_access.prefix_length
  network       = var.network
}

resource "google_service_networking_connection" "private_service_access" {
  count = var.private_service_access == null ? 0 : 1

  network                 = var.network
  service                 = var.private_service_access.service
  reserved_peering_ranges = [google_compute_global_address.private_service_access[0].name]
  deletion_policy         = "ABANDON"
}

resource "google_compute_network_peering_routes_config" "psa_routes" {
  count = (
    var.private_service_access != null &&
    var.network_name != "" &&
    (
      var.private_service_access.import_custom_routes ||
      var.private_service_access.export_custom_routes
    )
  ) ? 1 : 0

  project              = var.project_id
  peering              = google_service_networking_connection.private_service_access[0].peering
  network              = var.network_name
  import_custom_routes = var.private_service_access.import_custom_routes
  export_custom_routes = var.private_service_access.export_custom_routes
}

# --- Private Service Connect (PSC) ---

resource "google_compute_address" "psc" {
  for_each = var.psc_endpoints

  project      = var.project_id
  name         = coalesce(each.value.address_name, "${each.key}-address")
  region       = each.value.region
  address_type = "INTERNAL"
  subnetwork   = each.value.subnetwork
  address      = each.value.ip_address
  labels       = var.labels
}

resource "google_compute_forwarding_rule" "psc" {
  for_each = var.psc_endpoints

  project                 = var.project_id
  name                    = coalesce(each.value.forwarding_rule_name, each.key)
  region                  = each.value.region
  network                 = var.network
  subnetwork              = each.value.subnetwork
  ip_address              = google_compute_address.psc[each.key].id
  target                  = each.value.service_attachment
  allow_psc_global_access = each.value.allow_global_access
  load_balancing_scheme   = ""
  labels                  = var.labels
}

# --- Private Google Access (PGA) Subnets ---

resource "google_compute_subnetwork" "pga" {
  for_each = var.pga_subnets

  project = var.project_id
  name    = each.key
  region  = each.value.region
  network = var.network

  ip_cidr_range = each.value.ip_cidr_range
  description   = each.value.description

  stack_type       = each.value.stack_type
  ipv6_access_type = each.value.ipv6_access_type

  private_ip_google_access   = true
  private_ipv6_google_access = each.value.private_ipv6_google_access
}