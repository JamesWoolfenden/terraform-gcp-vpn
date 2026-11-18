resource "google_compute_subnetwork" "vpn" {
  name                     = "vpn-example"
  ip_cidr_range            = "10.92.0.0/24"
  region                   = "europe-west2"
  network                  = google_compute_network.vpn.id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
