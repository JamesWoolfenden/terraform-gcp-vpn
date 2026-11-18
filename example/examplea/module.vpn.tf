# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "vpn" {
  source                = "../../"
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

  labels = {
    environment = "example"
  }
}
