resource "google_compute_router_interface" "main" {
  for_each = local.tunnels

  name       = "${var.name}-interface-${each.key}"
  region     = var.region
  router     = google_compute_router.main.name
  ip_range   = each.value.router_ip_range
  vpn_tunnel = google_compute_vpn_tunnel.main[each.key].name
}
