output "ha_vpn_gateway_id" {
  value       = google_compute_ha_vpn_gateway.main.id
  description = "ID of the HA VPN gateway"
}

output "ha_vpn_gateway_interfaces" {
  value       = google_compute_ha_vpn_gateway.main.vpn_interfaces
  description = "Public IP addresses of the HA VPN gateway interfaces, to configure on the peer side"
}

output "external_vpn_gateway_id" {
  value       = google_compute_external_vpn_gateway.peer.id
  description = "ID of the external (peer) VPN gateway"
}

output "router_id" {
  value       = google_compute_router.main.id
  description = "ID of the Cloud Router"
}

output "tunnel_ids" {
  value = [
    google_compute_vpn_tunnel.main["0"].id,
    google_compute_vpn_tunnel.main["1"].id,
  ]
  description = "IDs of the two VPN tunnels"
}

output "router_peer_ids" {
  value = [
    google_compute_router_peer.main["0"].id,
    google_compute_router_peer.main["1"].id,
  ]
  description = "IDs of the two BGP peers"
}
