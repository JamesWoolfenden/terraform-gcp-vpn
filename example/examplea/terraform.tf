# holden:ignore:HLD_TF_004
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.31.0"
    }
  }
  required_version = ">= 1.9.0" # cross-variable validation (var.shared_secret referenced from var.shared_secret_version) requires 1.9+
}
