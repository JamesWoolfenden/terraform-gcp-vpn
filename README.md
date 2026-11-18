# terraform-gcp-vpn

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-vpn/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-vpn/actions)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-vpn.svg)](https://github.com/JamesWoolfenden/terraform-gcp-vpn/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-vpn.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-vpn/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.9.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for Cloud HA VPN. Creates an HA VPN gateway, an external (peer) VPN gateway, a Cloud Router with a private BGP ASN, and two IKEv2 tunnels each with its own router interface and BGP peer, giving the 99.99% HA VPN SLA topology. The pre-shared key comes either from a sensitive variable or from a Secret Manager secret version, and must be at least 32 characters; BGP MD5 authentication is optional.

## Usage

Add **module.vpn.tf** to your code:-

```terraform
module "vpn" {
  source                = "jameswoolfenden/vpn/gcp"
  name                  = "example-vpn"
  region                = "europe-west2"
  network               = google_compute_network.vpn.id
  router_asn            = 64514
  peer_asn              = 65001
  peer_ip_addresses     = ["203.0.113.10", "203.0.113.11"]
  shared_secret_version = google_secret_manager_secret_version.vpn.name

  bgp_sessions = [
    { router_ip_range = "169.254.10.1/30", peer_ip_address = "169.254.10.2" },
    { router_ip_range = "169.254.11.1/30", peer_ip_address = "169.254.11.2" },
  ]
}
```

See [example/examplea](example/examplea) for a complete working example.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_compute_external_vpn_gateway.peer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_external_vpn_gateway) | resource |
| [google_compute_ha_vpn_gateway.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ha_vpn_gateway) | resource |
| [google_compute_router.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_interface.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_interface) | resource |
| [google_compute_router_peer.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer) | resource |
| [google_compute_vpn_tunnel.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_tunnel) | resource |
| [google_secret_manager_secret_version.shared_secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_advertised_ip_ranges"></a> [advertised\_ip\_ranges](#input\_advertised\_ip\_ranges) | Extra CIDR ranges the Cloud Router advertises in addition to all subnets; empty uses DEFAULT advertisement | `list(string)` | `[]` | no |
| <a name="input_advertised_route_priority"></a> [advertised\_route\_priority](#input\_advertised\_route\_priority) | Base MED for routes advertised to the peer (lower is preferred) | `number` | `100` | no |
| <a name="input_bgp_md5_key"></a> [bgp\_md5\_key](#input\_bgp\_md5\_key) | Optional MD5 authentication key for the BGP sessions; must match the peer's configuration | `string` | `null` | no |
| <a name="input_bgp_sessions"></a> [bgp\_sessions](#input\_bgp\_sessions) | Two BGP sessions, one per tunnel: the Cloud Router interface link-local /30 (e.g. 169.254.0.1/30) and the peer's address in the same /30 | <pre>list(object({<br/>    router_ip_range = string<br/>    peer_ip_address = string<br/>  }))</pre> | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the HA VPN gateway, external gateway and tunnels | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the HA VPN gateway, router, tunnels, interfaces and BGP peers | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Self link or ID of the VPC network the HA VPN gateway and Cloud Router attach to | `string` | n/a | yes |
| <a name="input_peer_asn"></a> [peer\_asn](#input\_peer\_asn) | BGP ASN of the peer VPN gateway | `number` | n/a | yes |
| <a name="input_peer_ip_addresses"></a> [peer\_ip\_addresses](#input\_peer\_ip\_addresses) | Public IPv4 address(es) of the peer VPN gateway: one (SINGLE\_IP\_INTERNALLY\_REDUNDANT) or two (TWO\_IPS\_REDUNDANCY) | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for the HA VPN gateway, Cloud Router and tunnels | `string` | `"europe-west2"` | no |
| <a name="input_router_asn"></a> [router\_asn](#input\_router\_asn) | Private BGP ASN for the Cloud Router (64512-65534 or 4200000000-4294967294) | `number` | `64514` | no |
| <a name="input_shared_secret"></a> [shared\_secret](#input\_shared\_secret) | IKE pre-shared key for both tunnels (at least 32 characters). Set this or var.shared\_secret\_version, not both | `string` | `null` | no |
| <a name="input_shared_secret_version"></a> [shared\_secret\_version](#input\_shared\_secret\_version) | Secret Manager secret version holding the IKE pre-shared key, as projects/PROJECT/secrets/SECRET/versions/VERSION. Set this or var.shared\_secret, not both | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_external_vpn_gateway_id"></a> [external\_vpn\_gateway\_id](#output\_external\_vpn\_gateway\_id) | ID of the external (peer) VPN gateway |
| <a name="output_ha_vpn_gateway_id"></a> [ha\_vpn\_gateway\_id](#output\_ha\_vpn\_gateway\_id) | ID of the HA VPN gateway |
| <a name="output_ha_vpn_gateway_interfaces"></a> [ha\_vpn\_gateway\_interfaces](#output\_ha\_vpn\_gateway\_interfaces) | Public IP addresses of the HA VPN gateway interfaces, to configure on the peer side |
| <a name="output_router_id"></a> [router\_id](#output\_router\_id) | ID of the Cloud Router |
| <a name="output_router_peer_ids"></a> [router\_peer\_ids](#output\_router\_peer\_ids) | IDs of the two BGP peers |
| <a name="output_tunnel_ids"></a> [tunnel\_ids](#output\_tunnel\_ids) | IDs of the two VPN tunnels |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Role and Permissions

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "compute.externalVpnGateways.create",
    "compute.externalVpnGateways.delete",
    "compute.externalVpnGateways.get",
    "compute.externalVpnGateways.setLabels",
    "compute.globalOperations.get",
    "compute.routers.create",
    "compute.routers.delete",
    "compute.routers.get",
    "compute.routers.update",
    "compute.vpnGateways.create",
    "compute.vpnGateways.delete",
    "compute.vpnGateways.get",
    "compute.vpnGateways.setLabels",
    "compute.vpnTunnels.create",
    "compute.vpnTunnels.delete",
    "compute.vpnTunnels.get",
    "compute.vpnTunnels.setLabels",
    "secretmanager.versions.get"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "compute.externalVpnGateways.get",
    "compute.routers.get",
    "compute.vpnGateways.get",
    "compute.vpnTunnels.get",
    "secretmanager.versions.get"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/jameswoolfenden/terraform-gcp-vpn/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jameswoolfenden/terraform-gcp-vpn/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
