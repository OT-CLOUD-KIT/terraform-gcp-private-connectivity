terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "private_connectivity" {
  source = "../../"

  project_id = var.project_id
  network    = var.network

  private_service_access = {
    name          = "demo-psa-range"
    address       = var.psa_range
    prefix_length = var.psa_prefix_length
  }

  psc_endpoints = {
    "demo-psc-endpoint" = {
      region              = var.region
      service_attachment  = var.psc_service_attachment
      subnetwork          = var.psc_subnetwork
      allow_global_access = false
    }
  }

  pga_subnets = {
    "demo-pga-subnet" = {
      region                     = var.region
      ip_cidr_range              = var.pga_subnet_cidr
      description                = "Demo subnet with Private Google Access enabled"
      stack_type                 = "IPV4_IPV6"
      ipv6_access_type           = "INTERNAL"
      private_ipv6_google_access = "ENABLE_OUTBOUND_VM_ACCESS_TO_GOOGLE"
    }
  }

  labels = {
    managed_by  = "terraform"
    environment = "demo"
  }
}

output "psa_range_name" {
  value = module.private_connectivity.private_service_access_range_name
}

output "psc_endpoint_ips" {
  value = module.private_connectivity.psc_endpoint_ips
}

output "pga_subnet_self_links" {
  value = module.private_connectivity.pga_subnet_self_links
}
