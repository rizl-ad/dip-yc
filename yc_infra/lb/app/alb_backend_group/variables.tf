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

variable "grpc_backend" {
  type = list(object({
    name = string
    port = optional(number)
    target_group_ids = list(string)
    weight = optional(number)
    healthcheck = optional(list(object({
      healthcheck_port = optional(number)
      healthy_threshold = optional(number)
      interval = string
      interval_jitter_delay = optional(number)
      timeout = string
      unhealthy_threshold = optional(number)
      grpc_healthcheck = optional(object({
        service_name = optional(string)
      }))
      http_healthcheck = optional(object({
        expected_statuses = optional(list(number))
        host = optional(string)
        http2 = optional(bool)
        path = string
      }))
      stream_healthcheck = optional(object({
        receive = optional(string)
        send = optional(string)
      }))
    })))
    load_balancing_config = optional(object({
      locality_aware_routing_percent = optional(number)
      mode = optional(string, "ROUND_ROBIN")
      panic_threshold = optional(number)
      strict_locality = optional(bool)
    }))
    tls = optional(object({
      sni = optional(string)
      validation_context = optional(object({
        trusted_ca_bytes = optional(string)
        trusted_ca_id = optional(string)
      }))
    }))
  }))
  default = null
  validation {
    condition = var.grpc_backend != null ? alltrue([
      for gb in var.grpc_backend: gb.load_balancing_config != null && gb.load_balancing_config.mode !=null ? contains(
        ["ROUND_ROBIN", "RANDOM", "LEAST_REQUEST", "MAGLEV_HASH"], gb.load_balancing_config.mode
      ) : true
    ]) : true
    error_message = "Invalid application load balancer gRPC backend loadbalancing config mode, valid values: \"ROUND_ROBIN\", \"RANDOM\", \"LEAST_REQUEST\", \"MAGLEV_HASH\""
  }
}

variable "http_backend" {
  type = list(object({
    http2 = optional(bool)
    name = string
    port = optional(number)
    storage_bucket = optional(string)
    target_group_ids = optional(list(string))
    weight = optional(number)
    healthcheck = optional(list(object({
      healthcheck_port = optional(number)
      healthy_threshold = optional(number)
      interval = string
      interval_jitter_percent = optional(number)
      timeout = string
      unhealthy_threshold = optional(number)
      grpc_healthcheck = optional(object({
        service_name = optional(string)
      }))
      http_healthcheck = optional(object({
        expected_statuses = optional(list(number))
        host = optional(string)
        http2 = optional(bool)
        path = string
      }))
      stream_healthcheck = optional(object({
        receive = optional(string)
        send = optional(string)
      }))
    })))
    load_balancing_config = optional(object({
      locality_aware_routing_percent = optional(number)
      mode = optional(string, "ROUND_ROBIN")
      panic_threshold = optional(number)
      strict_locality = optional(bool)
    }))
    tls = optional(object({
      sni = optional(string)
      validation_context = optional(object({
        trusted_ca_bytes = optional(string)
        trusted_ca_id = optional(string)
      }))
    }))
  }))
  default = null
  validation {
    condition = var.http_backend != null ? alltrue([
      for hb in var.http_backend: hb.load_balancing_config != null && hb.load_balancing_config.mode !=null ? contains(
        ["ROUND_ROBIN", "RANDOM", "LEAST_REQUEST", "MAGLEV_HASH"], hb.load_balancing_config.mode
      ) : true
    ]) : true
    error_message = "Invalid application load balancer HTTP backend loadbalancing config mode, valid values: \"ROUND_ROBIN\", \"RANDOM\", \"LEAST_REQUEST\", \"MAGLEV_HASH\""
  }
}

variable "session_affinity" {
  type = object({
    connection = optional(object({
      source_ip = optional(bool)
    }))
    cookie = optional(object({
      name = string
      path = optional(string)
      ttl = optional(string)
    }))
    header = optional(object({
      header_name = string
    }))
  })
  default = null
}

variable "stream_backend" {
  type = list(object({
    enable_proxy_protocol = optional(bool)
    keep_connections_on_host_health_failure = optional(bool)
    name = string
    port = optional(number)
    target_group_ids = list(string)
    weight = optional(number)
    healthcheck = optional(list(object({
      healthcheck_port = optional(number)
      healthy_threshold = optional(number)
      interval = string
      interval_jitter_percent = optional(number)
      timeout = string
      unhealthy_threshold = optional(number)
      grpc_healthcheck = optional(object({
        service_name = optional(string)
      }))
      http_healthcheck = optional(object({
        expected_statuses = optional(list(number))
        host = optional(string)
        http2 = optional(bool)
        path = string
      }))
      stream_healthcheck = optional(object({
        receive = optional(string)
        send = optional(string)
      }))
    })))
    load_balancing_config = optional(object({
      locality_aware_routing_percent = optional(number)
      mode = optional(string, "ROUND_ROBIN")
      panic_threshold = optional(number)
      strict_locality = optional(bool)
    }))
    tls = optional(object({
      sni = optional(string)
      validation_context = optional(object({
        trusted_ca_bytes = optional(string)
        trusted_ca_id = optional(string)
      }))
    }))
  }))
  default = null
  validation {
    condition = var.stream_backend != null ? alltrue([
      for sb in var.stream_backend: sb.load_balancing_config != null && sb.load_balancing_config.mode !=null ? contains(
        ["ROUND_ROBIN", "RANDOM", "LEAST_REQUEST", "MAGLEV_HASH"], sb.load_balancing_config.mode
      ) : true
    ]) : true
    error_message = "Invalid application load balancer stream backend loadbalancing config mode, valid values: \"ROUND_ROBIN\", \"RANDOM\", \"LEAST_REQUEST\", \"MAGLEV_HASH\""
  }
}
