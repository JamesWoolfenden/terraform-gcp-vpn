resource "google_compute_router" "main" {
  name        = "${var.name}-router"
  region      = var.region
  network     = var.network
  description = "Cloud Router carrying BGP for ${var.name}"

  bgp {
    asn               = var.router_asn
    advertise_mode    = local.advertise_mode
    advertised_groups = local.advertised_groups

    dynamic "advertised_ip_ranges" {
      for_each = var.advertised_ip_ranges
      content {
        range = advertised_ip_ranges.value
      }
    }
  }
}
