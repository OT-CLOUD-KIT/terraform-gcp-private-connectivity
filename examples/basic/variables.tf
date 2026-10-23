
variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "network" {
  description = "Self-link or ID of the existing VPC network."
  type        = string
}

variable "region" {
  description = "Region for PSC endpoint and PGA subnet."
  type        = string
  default     = "asia-south1"
}

variable "psc_service_attachment" {
  description = "Full URI of the published service attachment."
  type        = string
}

variable "psc_subnetwork" {
  description = "Existing subnet URI for the PSC endpoint address."
  type        = string
}

variable "psa_range" {
  description = "Non-overlapping IPv4 range reserved for PSA."
  type        = string
  default     = "10.240.0.0"
}

variable "psa_prefix_length" {
  description = "Prefix length for the PSA allocated range."
  type        = number
  default     = 16
}

variable "pga_subnet_cidr" {
  description = "Unused CIDR range for the new PGA subnet."
  type        = string
  default     = "10.30.0.0/24"
}
