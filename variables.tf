variable "name" {
  type        = string
  description = "Base name for the HA VPN gateway, router, tunnels, interfaces and BGP peers"

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,40}[a-z0-9])?$", var.name))
    error_message = "var.name must be a lowercase RFC1035 name of at most 42 characters (suffixes are appended to it)"
  }
}

variable "region" {
  type        = string
  description = "Region for the HA VPN gateway, Cloud Router and tunnels"
  default     = "europe-west2"

  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "var.region must be a non-empty string"
  }
}

variable "network" {
  type        = string
  description = "Self link or ID of the VPC network the HA VPN gateway and Cloud Router attach to"

  validation {
    condition     = length(trimspace(var.network)) > 0
    error_message = "var.network must be a non-empty string"
  }
}

variable "router_asn" {
  type        = number
  description = "Private BGP ASN for the Cloud Router (64512-65534 or 4200000000-4294967294)"
  default     = 64514

  validation {
    condition     = (var.router_asn >= 64512 && var.router_asn <= 65534) || (var.router_asn >= 4200000000 && var.router_asn <= 4294967294)
    error_message = "var.router_asn must be a private ASN: 64512-65534 or 4200000000-4294967294"
  }
}

variable "peer_asn" {
  type        = number
  description = "BGP ASN of the peer VPN gateway"

  validation {
    condition     = var.peer_asn >= 1 && var.peer_asn <= 4294967294
    error_message = "var.peer_asn must be a valid BGP ASN (1-4294967294)"
  }
}

variable "peer_ip_addresses" {
  type        = list(string)
  description = "Public IPv4 address(es) of the peer VPN gateway: one (SINGLE_IP_INTERNALLY_REDUNDANT) or two (TWO_IPS_REDUNDANCY)"

  validation {
    condition     = length(var.peer_ip_addresses) >= 1 && length(var.peer_ip_addresses) <= 2 && alltrue([for ip in var.peer_ip_addresses : can(cidrhost("${ip}/32", 0))])
    error_message = "var.peer_ip_addresses must contain one or two valid IPv4 addresses"
  }
}

variable "bgp_sessions" {
  type = list(object({
    router_ip_range = string
    peer_ip_address = string
  }))
  description = "Two BGP sessions, one per tunnel: the Cloud Router interface link-local /30 (e.g. 169.254.0.1/30) and the peer's address in the same /30"

  validation {
    condition = length(var.bgp_sessions) == 2 && alltrue([
      for s in var.bgp_sessions :
      can(regex("^169\\.254\\.[0-9]{1,3}\\.[0-9]{1,3}/30$", s.router_ip_range)) &&
      can(cidrhost(s.router_ip_range, 0)) &&
      can(regex("^169\\.254\\.", s.peer_ip_address)) &&
      cidrhost(s.router_ip_range, 0) == cidrhost("${s.peer_ip_address}/30", 0)
    ])
    error_message = "var.bgp_sessions must contain exactly two entries; each router_ip_range must be a 169.254.0.0/16 /30 and peer_ip_address must sit in the same /30"
  }
}

variable "shared_secret" {
  type        = string
  description = "IKE pre-shared key for both tunnels (at least 32 characters). Set this or var.shared_secret_version, not both"
  default     = null
  sensitive   = true

  validation {
    condition     = var.shared_secret == null || length(coalesce(var.shared_secret, "x")) >= 32
    error_message = "var.shared_secret must be at least 32 characters long"
  }
}

variable "shared_secret_version" {
  type        = string
  description = "Secret Manager secret version holding the IKE pre-shared key, as projects/PROJECT/secrets/SECRET/versions/VERSION. Set this or var.shared_secret, not both"
  default     = null
  sensitive   = true

  validation {
    condition     = var.shared_secret_version == null || can(regex("^projects/[^/]+/secrets/[^/]+/versions/[^/]+$", coalesce(var.shared_secret_version, "x")))
    error_message = "var.shared_secret_version must look like projects/PROJECT/secrets/SECRET/versions/VERSION"
  }

  validation {
    condition     = (var.shared_secret_version == null) != (var.shared_secret == null)
    error_message = "Set exactly one of var.shared_secret or var.shared_secret_version"
  }
}

variable "bgp_md5_key" {
  type        = string
  description = "Optional MD5 authentication key for the BGP sessions; must match the peer's configuration"
  default     = null
  sensitive   = true

  validation {
    condition     = var.bgp_md5_key == null || (length(coalesce(var.bgp_md5_key, "x")) >= 1 && length(coalesce(var.bgp_md5_key, "x")) <= 80)
    error_message = "var.bgp_md5_key must be 1-80 characters when set"
  }
}

variable "advertised_ip_ranges" {
  type        = list(string)
  description = "Extra CIDR ranges the Cloud Router advertises in addition to all subnets; empty uses DEFAULT advertisement"
  default     = []

  validation {
    condition     = alltrue([for r in var.advertised_ip_ranges : can(cidrhost(r, 0))])
    error_message = "var.advertised_ip_ranges must contain valid CIDR ranges"
  }
}

variable "advertised_route_priority" {
  type        = number
  description = "Base MED for routes advertised to the peer (lower is preferred)"
  default     = 100

  validation {
    condition     = var.advertised_route_priority >= 0 && var.advertised_route_priority <= 65535
    error_message = "var.advertised_route_priority must be between 0 and 65535"
  }
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the HA VPN gateway, external gateway and tunnels"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.labels : can(regex("^[a-z0-9_-]{1,63}$", k)) && can(regex("^[a-z0-9_-]{0,63}$", v))])
    error_message = "var.labels keys and values must be lowercase alphanumerics, underscores, or hyphens, 1-63 characters (GCP label constraints)"
  }
}
