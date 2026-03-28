variable "allow_zonal_shift" {
  type    = bool
  default = null
}

variable "deletion_protection" {
  type    = bool
  default = null
}

variable "description" {
  type    = string
  default = null
}

variable "folder_id" {
  type    = string
  default = null
}

variable "labels" {
  type    = map(string)
  default = null
}

variable "name" {
  type    = string
  default = null
}

variable "region_id" {
  type    = string
  default = null
}

variable "type" {
  type    = string
  default = "external"
  validation {
    condition     = contains(["external", "internal"], var.type)
    error_message = "Invalid network load balancer type, valid values: \"external\", \"internal\""
  }
}

variable "attached_target_group" {
  type = object({
    target_group_id = string
    healthcheck = optional(object({
      healthy_threshold   = optional(number, 2)
      interval            = optional(number, 2)
      name                = string
      timeout             = optional(number, 1)
      unhealthy_threshold = optional(number, 2)
      http_options = optional(object({
        path = optional(string, "/")
        port = number
      }))
      tcp_options = optional(object({
        port = number
      }))
    }))
  })
  default = null
}

variable "listener" {
  type = object({
    name        = string
    port        = number
    protocol    = optional(string, "tcp")
    target_port = optional(number)
    external_address_spec = optional(object({
      address    = optional(string)
      ip_version = optional(string, "ipv4")
    }))
    internal_address_spec = optional(object({
      address    = optional(string)
      ip_version = optional(string, "ipv4")
      subnet_id  = string
    }))
  })
  validation {
    condition     = contains(["tcp", "udp"], var.listener.protocol)
    error_message = "Invalid network load balancer listener protocol, valid values: \"tcp\", \"udp\""
  }
  validation {
    condition = var.listener.external_address_spec != null && var.listener.external_address_spec.address != null ? (
      can(cidrhost("${var.listener.external_address_spec.address}/32", 0)) ||
      can(cidrhost("${var.listener.external_address_spec.address}/128", 0))
    ) : true
    error_message = "Network load balancer listener external address must be a valid IPv4 or IPv6 address"
  }
  validation {
    condition = var.listener.external_address_spec != null ? contains(
      ["ipv4", "ipv6"], var.listener.external_address_spec.ip_version
    ) : true
    error_message = "Invalid network load balancer listener external ip-address version, valid values: \"ipv4\", \"ipv6\""
  }
  validation {
    condition = var.listener.internal_address_spec != null && var.listener.internal_address_spec.address != null ? (
      can(cidrhost("${var.listener.internal_address_spec.address}/32", 0)) ||
      can(cidrhost("${var.listener.internal_address_spec.address}/128", 0))
    ) : true
    error_message = "Network load balancer listener internal address must be a valid IPv4 or IPv6 address"
  }
  validation {
    condition     = var.listener.internal_address_spec != null ? contains(["ipv4", "ipv6"], var.listener.internal_address_spec.ip_version) : true
    error_message = "Invalid network load balancer listener internal ip-address version, valid values: \"ipv4\", \"ipv6\""
  }
  validation {
    condition     = (var.listener.external_address_spec != null) != (var.listener.internal_address_spec != null)
    error_message = "Either \"external_address_spec\" or \"internal_address_spec\" network load balancer listener block must be specified"
  }
}

