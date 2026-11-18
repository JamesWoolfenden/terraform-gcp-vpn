resource "google_compute_external_vpn_gateway" "peer" {
  name            = "${var.name}-peer"
  description     = "Peer (on-premises or other cloud) VPN gateway for ${var.name}"
  redundancy_type = local.redundancy_type
  labels          = var.labels

  dynamic "interface" {
    for_each = var.peer_ip_addresses
    content {
      id         = interface.key
      ip_address = interface.value
    }
  }
}
