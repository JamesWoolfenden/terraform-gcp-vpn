resource "google_compute_ha_vpn_gateway" "main" {
  name        = var.name
  region      = var.region
  network     = var.network
  description = "HA VPN gateway for ${var.name}"
  stack_type  = "IPV4_ONLY"
  labels      = var.labels
}
