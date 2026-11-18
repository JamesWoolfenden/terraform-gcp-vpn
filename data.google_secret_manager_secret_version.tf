# Only read when the shared secret is supplied by reference to Secret Manager
# rather than directly through var.shared_secret.
data "google_secret_manager_secret_version" "shared_secret" {
  count   = nonsensitive(var.shared_secret_version != null) ? 1 : 0
  secret  = local.shared_secret_id
  version = local.shared_secret_version_number
}
