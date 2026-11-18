resource "google_compute_vpn_tunnel" "main" {
  for_each = local.tunnels

  name                            = "${var.name}-tunnel-${each.key}"
  region                          = var.region
  description                     = "HA VPN tunnel ${each.key} for ${var.name}"
  vpn_gateway                     = google_compute_ha_vpn_gateway.main.id
  vpn_gateway_interface           = each.value.vpn_gateway_interface
  peer_external_gateway           = google_compute_external_vpn_gateway.peer.id
  peer_external_gateway_interface = each.value.peer_external_gateway_interface
  router                          = google_compute_router.main.id
  ike_version                     = 2
  shared_secret                   = local.shared_secret
  labels                          = var.labels

  lifecycle {
    precondition {
      condition     = length(local.shared_secret) >= 32
      error_message = "The VPN shared secret must be at least 32 characters long"
    }
  }
}
