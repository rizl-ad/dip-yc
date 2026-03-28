variable "allow_zonal_shift" {
  type = bool
  default = null
}

variable "description" {
  type = string
  default = null
}

variable "folder_id" {
  type = string
  default = null
}

variable "labels" {
  type = map(string)
  default = null
}

variable "name" {
  type = string
  default = null
}

variable "network_id" {
  type = string
}

variable "region_id" {
  type = string
  default = null
}

variable "security_group_ids" {
  type = set(string)
  default = null
}

variable "allocation_policy" {
  type = object({
    location = list(object({
      disable_traffic = optional(bool)
      subnet_id = string
      zone_id = string
    }))
  })
}

variable "auto_scale_policy" {
  type = object({
    max_size = optional(number)
    min_zone_size = optional(number)
  })
  default = null
}

variable "listener" {
  type = list(object({
    name = string
    endpoint = optional(object({
      ports = list(number)
      address = optional(object({
        external_ipv4_address = optional(object({
          address = optional(string)
        }))
        external_ipv6_address = optional(object({
          address = optional(string)
        }))
        internal_ipv4_address = optional(object({
          address = optional(string)
          subnet_id = optional(string)
        }))
      }))
    }))
    http = optional(object({
      handler = optional(object({
        allow_http10 = optional(bool)
        http_router_id = optional(string)
        rewrite_request_id = optional(bool)
        http2_options = optional(object({
          max_concurrent_streams = optional(number)
        }))
      }))
      redirects = optional(object({
        http_to_https = optional(bool)
      }))
    }))
    stream = optional(object({
      handler = optional(object({
        backend_group_id = optional(string)
        idle_timeout = optional(string)
      }))
    }))
    tls = optional(object({
      default_handler = optional(object({
        certificate_ids = set(string)
        http_handler = optional(object({
          allow_http10 = optional(bool)
          http_router_id = optional(string)
          rewrite_request_id = optional(bool)
          http2_options = optional(object({
            max_concurrent_streams = optional(number)
          }))
        }))
        stream_handler = optional(object({
          backend_group_id = optional(string)
          idle_timeout = optional(string)
        }))
      }))
      sni_handler = optional(list(object({
        name = string
        server_names = set(string)
        handler = optional(object({
          certificate_ids = set(string)
          http_handler = optional(object({
            allow_http10 = optional(bool)
            http_router_id = optional(string)
            rewrite_request_id = optional(bool)
            http2_options = optional(object({
              max_concurrent_streams = optional(number)
            }))
          }))
          stream_handler = optional(object({
            backend_group_id = optional(string)
            idle_timeout = optional(string)
          }))
        }))
      })))
    }))
  }))
  default = null
  validation {
    condition = (
      var.listener != null ? alltrue([
        for ls in var.listener : (
          ls.endpoint != null && ls.endpoint.address != null && ls.endpoint.address.external_ipv4_address != null &&
          ls.endpoint.address.external_ipv4_address.address != null
        ) ? can(cidrhost("${ls.endpoint.address.external_ipv4_address.address}/32", 0)) : true
      ]) : true
    )
    error_message = "Application load balancer listener external address must be a valid IPv4 or IPv6 address"
  }
  validation {
    condition = (
      var.listener != null ? alltrue([
        for ls in var.listener : (
          ls.endpoint != null && ls.endpoint.address != null && ls.endpoint.address.external_ipv6_address != null &&
          ls.endpoint.address.external_ipv6_address.address != null
        ) ? can(cidrhost("${ls.endpoint.address.external_ipv6_address.address}/32", 0)) : true
      ]) : true
    )
    error_message = "Application load balancer listener external address must be a valid IPv4 or IPv6 address"
  }
  validation {
    condition = (
      var.listener != null ? alltrue([
        for ls in var.listener : (
          ls.endpoint != null && ls.endpoint.address != null && ls.endpoint.address.internal_ipv4_address != null &&
          ls.endpoint.address.internal_ipv4_address.address != null
        ) ? can(cidrhost("${ls.endpoint.address.internal_ipv4_address.address}/32", 0)) : true
      ]) : true
    )
    error_message = "Application load balancer listener internal address must be a valid IPv4 address"
  }
}

variable "log_options" {
  type = object({
    disable = optional(bool)
    log_group_id = optional(string)
    discard_rule = optional(list(object({
      discard_percent = optional(number)
      grpc_codes = optional(list(string))
      http_code_intervals = optional(list(string))
      http_codes = optional(list(number))
    })))
  })
  default = null
}



