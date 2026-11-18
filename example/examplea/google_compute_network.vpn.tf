# holden:ignore:HLD_GCP_093: Just enough to drive the module
# holden:ignore:HLD_GCP_303 — the replacement routes for this network are the
# on-premises prefixes learned over BGP through module.vpn, not a static route.
resource "google_compute_network" "vpn" {
  name                            = "vpn-example"
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
}
