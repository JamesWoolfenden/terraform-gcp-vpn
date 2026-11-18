# holden:ignore:HLD_GCP_123 — the PSK is rotated out-of-band in step with the
# peer device; a Terraform rotation schedule would not change the peer side.
resource "google_secret_manager_secret" "vpn" {
  secret_id = "vpn-example-psk"

  replication {
    auto {}
  }
}
