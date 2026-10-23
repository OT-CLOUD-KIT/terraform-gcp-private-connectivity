
variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "network" {
  description = "Self-link or ID of the existing VPC network."
  type        = string
}

variable "private_service_access" {
  description = "Optional Private Service Access configuration."
  type = object({
    name          = string
    address       = string
    prefix_length = number
    service       = optional(string, "servicenetworking.googleapis.com")
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
  description = "Subnets created with Private Google Access enabled."
  type = map(object({
    region                     = string
    ip_cidr_range              = string
    description                = optional(string)
    private_ipv6_google_access = optional(string)
  }))
  default = {}
}

variable "labels" {
  description = "Labels applied to supported resources."
  type        = map(string)
  default     = {}
}
