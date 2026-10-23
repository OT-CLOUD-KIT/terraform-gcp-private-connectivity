# Terraform GCP Private Connectivity

Reusable Terraform wrapper for Google Cloud private connectivity patterns.

## Scope

- Private Service Access (PSA) using a reserved IP range and Service Networking connection
- Private Service Connect (PSC) endpoints for published service attachments
- Private Google Access (PGA) enabled on subnets created by the module
- Support for an existing VPC
- Configurable regions, CIDR ranges, endpoint addresses, and global access
- Outputs for connection details, endpoint IP addresses, forwarding rules, and subnets

## Requirements

- Terraform 1.5 or later
- Compatible Google Terraform provider
- Existing Google Cloud project and VPC network
- Compute Engine API enabled
- Service Networking API enabled for PSA
- Required networking permissions for address allocation, forwarding rules, subnet creation, and private connections
- For PSC, an existing published service attachment and a suitable subnet in the endpoint region
- For PGA, a non-overlapping CIDR range for each new subnet

## Architecture

**PSA:** VPC → reserved peering range → Service Networking private connection.

**PSC:** VPC subnet → internal endpoint IP → forwarding rule → published service attachment.

**PGA:** VPC → regional subnet with `private_ip_google_access = true` → supported Google APIs.

## Usage

1. Configure credentials for the target Google Cloud project.
2. Copy `examples/basic/terraform.tfvars.example` to `examples/basic/terraform.tfvars`.
3. Replace the project, network, service attachment, subnet, and CIDR placeholders.
4. Enable the necessary APIs and verify IAM permissions.
5. Run formatting, initialization, and validation.
6. Review the Terraform plan before applying.

## Validation

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate

terraform -chdir=examples/basic init -backend=false
terraform -chdir=examples/basic validate
terraform -chdir=examples/basic plan
```

## Operational considerations

- PSA ranges must not overlap existing subnet, route, or other reserved address ranges. Choose a range appropriate to the service and future capacity requirements.
- PSA creates a private connection through VPC Network Peering. Peering limitations, including non-transitivity, apply.
- PSC endpoint region, subnet, and service attachment must be compatible. Global access is optional and must be supported by the use case.
- PGA enables private API access for eligible workloads in the subnet; it does not automatically create firewall rules or guarantee access to every Google service.
- The module creates new PGA subnets rather than adopting existing subnet resources.
- Review deletion behavior and dependencies before destroying PSA resources.
- Terraform validation does not prove that end-to-end private connectivity works.

## Official documentation

- [Private access options](https://docs.cloud.google.com/vpc/docs/private-access-options)
- [Private Service Access](https://docs.cloud.google.com/vpc/docs/configure-private-services-access)
- [PSC endpoints for published services](https://docs.cloud.google.com/vpc/docs/configure-private-service-connect-services)
- [Private Google Access](https://docs.cloud.google.com/vpc/docs/configure-private-google-access)
- [Terraform Service Networking connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection)
- [Terraform subnet resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork)
