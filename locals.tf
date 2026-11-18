locals {
  # Exactly one of var.shared_secret / var.shared_secret_version is set (enforced
  # by validation); resolve whichever was supplied into a single value.
  shared_secret = var.shared_secret != null ? var.shared_secret : data.google_secret_manager_secret_version.shared_secret[0].secret_data

  # var.shared_secret_version is a version path; the data source takes the
  # secret and the version separately.
  shared_secret_id             = try(split("/versions/", var.shared_secret_version)[0], null)
  shared_secret_version_number = try(split("/versions/", var.shared_secret_version)[1], null)

  # HA VPN needs two tunnels, one per HA gateway interface, for the 99.99% SLA.
  # With a single peer IP (SINGLE_IP_INTERNALLY_REDUNDANT) both tunnels land on
  # peer interface 0; with two peer IPs (TWO_IPS_REDUNDANCY) they are spread.
  two_peer_ips     = length(var.peer_ip_addresses) == 2
  redundancy_type  = local.two_peer_ips ? "TWO_IPS_REDUNDANCY" : "SINGLE_IP_INTERNALLY_REDUNDANT"
  peer_interface_1 = local.two_peer_ips ? 1 : 0

  tunnels = {
    "0" = {
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      router_ip_range                 = var.bgp_sessions[0].router_ip_range
      peer_ip_address                 = var.bgp_sessions[0].peer_ip_address
    }
    "1" = {
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = local.peer_interface_1
      router_ip_range                 = var.bgp_sessions[1].router_ip_range
      peer_ip_address                 = var.bgp_sessions[1].peer_ip_address
    }
  }

  # Advertise all subnets plus any extra ranges when ranges are given;
  # otherwise fall back to Cloud Router's DEFAULT advertisement.
  custom_advertisement = length(var.advertised_ip_ranges) > 0
  advertise_mode       = local.custom_advertisement ? "CUSTOM" : "DEFAULT"
  advertised_groups    = local.custom_advertisement ? ["ALL_SUBNETS"] : null
}
