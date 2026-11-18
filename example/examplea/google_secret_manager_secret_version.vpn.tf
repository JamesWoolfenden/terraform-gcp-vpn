resource "google_secret_manager_secret_version" "vpn" {
  secret      = google_secret_manager_secret.vpn.id
  secret_data = "placeholder-rotated-out-of-band-0123456789abcdef"
}
