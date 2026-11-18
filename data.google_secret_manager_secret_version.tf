# Only read when the shared secret is supplied by reference to Secret Manager
# rather than directly through var.shared_secret. Keyed off var.shared_secret
# (validation guarantees exactly one is set) because var.shared_secret_version
# is usually a resource attribute that is unknown until apply, which would make
# count unknown at plan time.
data "google_secret_manager_secret_version" "shared_secret" {
  count   = nonsensitive(var.shared_secret == null) ? 1 : 0
  secret  = local.shared_secret_id
  version = local.shared_secret_version_number
}
