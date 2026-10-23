variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "network" {
  description = "Self-link or ID of the existing VPC network."
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network. Required when PSA custom routes are enabled."
  type        = string
  default     = ""

  validation {
    condition = (
      var.private_service_access == null ||
      (
        !var.private_service_access.import_custom_routes &&
        !var.private_service_access.export_custom_routes
      ) ||
      trim(var.network_name) != ""
    )

    error_message = "network_name is required when PSA import_custom_routes or export_custom_routes is enabled."
  }
}

variable "private_service_access" {
  description = "Configuration for Private Service Access (Cloud SQL, Memorystore)."
  type = object({
    name                 = string
    address              = string
    prefix_length        = number
    service              = optional(string, "servicenetworking.googleapis.com")
    import_custom_routes = optional(bool, false)
    export_custom_routes = optional(bool, false)
  })
  default = null

  validation {
    condition = var.private_service_access == null ? true : (
      var.private_service_access.prefix_length >= 16 &&
      var.private_service_access.prefix_length <= 29
    )
    error_message = "PSA prefix_length must be between 16 and 29."
  }
}

variable "psc_endpoints" {
  description = "Private Service Connect endpoints to published service attachments."
  type = map(object({
    region               = string
    service_attachment   = string
    subnetwork           = string
    ip_address           = optional(string)
    allow_global_access  = optional(bool, false)
    address_name         = optional(string)
    forwarding_rule_name = optional(string)
  }))
  default = {}
}

variable "pga_subnets" {
  description = "Subnets to create with Private Google Access enabled."

  type = map(object({
    region                     = string
    ip_cidr_range              = string
    description                = optional(string)
    private_ipv6_google_access = optional(string)
    stack_type                 = optional(string, "IPV4_ONLY")
    ipv6_access_type           = optional(string)
  }))

  default = {}

  validation {
    condition = alltrue([
      for subnet in values(var.pga_subnets) :
      contains(["IPV4_ONLY", "IPV4_IPV6"], subnet.stack_type)
    ])

    error_message = "pga_subnets.stack_type must be IPV4_ONLY or IPV4_IPV6."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.pga_subnets) :
      subnet.ipv6_access_type == null ||
      contains(["INTERNAL", "EXTERNAL"], subnet.ipv6_access_type)
    ])

    error_message = "pga_subnets.ipv6_access_type must be INTERNAL or EXTERNAL."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.pga_subnets) :
      subnet.stack_type == "IPV4_ONLY" ||
      subnet.ipv6_access_type != null
    ])

    error_message = "ipv6_access_type must be provided when stack_type is IPV4_IPV6."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.pga_subnets) :
      subnet.private_ipv6_google_access == null ||
      subnet.stack_type == "IPV4_IPV6"
    ])

    error_message = "private_ipv6_google_access requires stack_type = IPV4_IPV6."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.pga_subnets) :
      subnet.private_ipv6_google_access == null ||
      contains([
        "DISABLE_GOOGLE_ACCESS",
        "ENABLE_OUTBOUND_VM_ACCESS_TO_GOOGLE",
        "ENABLE_BIDIRECTIONAL_ACCESS_TO_GOOGLE"
      ], subnet.private_ipv6_google_access)
    ])

    error_message = "private_ipv6_google_access must be DISABLE_GOOGLE_ACCESS, ENABLE_OUTBOUND_VM_ACCESS_TO_GOOGLE, or ENABLE_BIDIRECTIONAL_ACCESS_TO_GOOGLE."
  }
}

variable "labels" {
  description = "Labels applied to supported resources (addresses, forwarding rules)."
  type        = map(string)
  default     = {}
}