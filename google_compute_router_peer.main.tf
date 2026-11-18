resource "google_compute_router_peer" "main" {
  for_each = local.tunnels

  name                      = "${var.name}-peer-${each.key}"
  region                    = var.region
  router                    = google_compute_router.main.name
  interface                 = google_compute_router_interface.main[each.key].name
  peer_ip_address           = each.value.peer_ip_address
  peer_asn                  = var.peer_asn
  advertised_route_priority = var.advertised_route_priority

  dynamic "md5_authentication_key" {
    for_each = var.bgp_md5_key != null ? [1] : []
    content {
      name = "${var.name}-md5-${each.key}"
      key  = var.bgp_md5_key
    }
  }
}
