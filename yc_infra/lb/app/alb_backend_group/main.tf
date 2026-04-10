resource "yandex_alb_backend_group" "alb_backend_group" {
  description = var.description
  folder_id   = var.folder_id
  labels      = var.labels
  name        = var.name

  dynamic "grpc_backend" {
    for_each = var.grpc_backend != null ? var.grpc_backend : []
    content {
      name             = grpc_backend.value.name
      port             = grpc_backend.value.port
      target_group_ids = grpc_backend.value.target_group_ids
      weight           = grpc_backend.value.weight

      dynamic "healthcheck" {
        for_each = grpc_backend.value.healthcheck != null ? grpc_backend.value.healthcheck : []
        content {
          healthcheck_port        = healthcheck.value.healthcheck_port
          healthy_threshold       = healthcheck.value.healthy_threshold
          interval                = healthcheck.value.interval
          interval_jitter_percent = healthcheck.value.interval_jitter_percent
          timeout                 = healthcheck.value.timeout
          unhealthy_threshold     = healthcheck.value.unhealthy_threshold

          dynamic "grpc_healthcheck" {
            for_each = healthcheck.value.grpc_healthcheck != null ? [healthcheck.value.grpc_healthcheck] : []
            content {
              service_name = grpc_healthcheck.value.service_name
            }
          }

          dynamic "http_healthcheck" {
            for_each = healthcheck.value.http_healthcheck != null ? [healthcheck.value.http_healthcheck] : []
            content {
              expected_statuses = http_healthcheck.value.expected_statuses
              host              = http_healthcheck.value.host
              path              = http_healthcheck.value.path
              http2             = http_healthcheck.value.http2
            }
          }

          dynamic "stream_healthcheck" {
            for_each = healthcheck.value.stream_healthcheck != null ? [healthcheck.value.stream_healthcheck] : []
            content {
              receive = stream_healthcheck.value.receive
              send    = stream_healthcheck.value.send
            }
          }
        }
      }

      dynamic "load_balancing_config" {
        for_each = grpc_backend.value.load_balancing_config != null ? [grpc_backend.value.load_balancing_config] : []
        content {
          locality_aware_routing_percent = load_balancing_config.value.locality_aware_routing_percent
          mode                           = load_balancing_config.value.mode
          panic_threshold                = load_balancing_config.value.panic_threshold
          strict_locality                = load_balancing_config.value.strict_locality
        }
      }

      dynamic "tls" {
        for_each = grpc_backend.value.tls != null ? [grpc_backend.value.tls] : []
        content {
          sni = tls.value.sni

          dynamic "validation_context" {
            for_each = tls.value.validation_context != null ? [tls.value.validation_context] : []
            content {
              trusted_ca_bytes = validation_context.value.trusted_ca_bytes
              trusted_ca_id    = validation_context.value.trusted_ca_id
            }
          }
        }
      }

    }
  }

  dynamic "http_backend" {
    for_each = var.http_backend != null ? var.http_backend : []
    content {
      http2            = http_backend.value.http2
      name             = http_backend.value.name
      port             = http_backend.value.port
      storage_bucket   = http_backend.value.storage_bucket
      target_group_ids = http_backend.value.target_group_ids
      weight           = http_backend.value.weight

      dynamic "healthcheck" {
        for_each = http_backend.value.healthcheck != null ? http_backend.value.healthcheck : []
        content {
          healthcheck_port        = healthcheck.value.healthcheck_port
          healthy_threshold       = healthcheck.value.healthy_threshold
          interval                = healthcheck.value.interval
          interval_jitter_percent = healthcheck.value.interval_jitter_percent
          timeout                 = healthcheck.value.timeout
          unhealthy_threshold     = healthcheck.value.unhealthy_threshold

          dynamic "grpc_healthcheck" {
            for_each = healthcheck.value.grpc_healthcheck != null ? [healthcheck.value.grpc_healthcheck] : []
            content {
              service_name = grpc_healthcheck.value.service_name
            }
          }

          dynamic "http_healthcheck" {
            for_each = healthcheck.value.http_healthcheck != null ? [healthcheck.value.http_healthcheck] : []
            content {
              expected_statuses = http_healthcheck.value.expected_statuses
              host              = http_healthcheck.value.host
              http2             = http_healthcheck.value.http2
              path              = http_healthcheck.value.path
            }
          }

          dynamic "stream_healthcheck" {
            for_each = healthcheck.value.stream_healthcheck != null ? [healthcheck.value.stream_healthcheck] : []
            content {
              receive = stream_healthcheck.value.receive
              send    = stream_healthcheck.value.send
            }
          }
        }
      }

      dynamic "load_balancing_config" {
        for_each = http_backend.value.load_balancing_config != null ? [http_backend.value.load_balancing_config] : []
        content {
          locality_aware_routing_percent = load_balancing_config.value.locality_aware_routing_percent
          mode                           = load_balancing_config.value.mode
          panic_threshold                = load_balancing_config.value.panic_threshold
          strict_locality                = load_balancing_config.value.strict_locality
        }
      }

      dynamic "tls" {
        for_each = http_backend.value.tls != null ? [http_backend.value.tls] : []
        content {
          sni = tls.value.sni

          dynamic "validation_context" {
            for_each = tls.value.validation_context != null ? [tls.value.validation_context] : []
            content {
              trusted_ca_bytes = validation_context.value.trusted_ca_bytes
              trusted_ca_id    = validation_context.value.trusted_ca_id
            }
          }
        }
      }
    }
  }

  dynamic "session_affinity" {
    for_each = var.session_affinity != null ? [var.session_affinity] : []
    content {
      dynamic "connection" {
        for_each = session_affinity.value.connection != null ? [session_affinity.value.connection] : []
        content {
          source_ip = connection.value.source_ip
        }
      }

      dynamic "cookie" {
        for_each = session_affinity.value.cookie != null ? [session_affinity.value.cookie] : []
        content {
          name = cookie.value.name
          path = cookie.value.path
          ttl  = cookie.value.ttl
        }
      }

      dynamic "header" {
        for_each = session_affinity.value.header != null ? [session_affinity.value.header] : []
        content {
          header_name = header.value.header_name
        }
      }
    }
  }

  dynamic "stream_backend" {
    for_each = var.stream_backend != null ? var.stream_backend : []
    content {
      enable_proxy_protocol                   = stream_backend.value.enable_proxy_protocol
      keep_connections_on_host_health_failure = stream_backend.value.keep_connections_on_host_health_failure
      name                                    = stream_backend.value.name
      port                                    = stream_backend.value.port
      target_group_ids                        = stream_backend.value.target_group_ids
      weight                                  = stream_backend.value.weight

      dynamic "healthcheck" {
        for_each = stream_backend.value.healthcheck != null ? stream_backend.value.healthcheck : []
        content {
          healthcheck_port        = healthcheck.value.healthcheck_port
          healthy_threshold       = healthcheck.value.healthy_threshold
          interval                = healthcheck.value.interval
          interval_jitter_percent = healthcheck.value.interval_jitter_percent
          timeout                 = healthcheck.value.timeout
          unhealthy_threshold     = healthcheck.value.unhealthy_threshold

          dynamic "grpc_healthcheck" {
            for_each = healthcheck.value.grpc_healthcheck != null ? [healthcheck.value.grpc_healthcheck] : []
            content {
              service_name = grpc_healthcheck.value.service_name
            }
          }

          dynamic "http_healthcheck" {
            for_each = healthcheck.value.http_healthcheck != null ? [healthcheck.value.http_healthcheck] : []
            content {
              expected_statuses = http_healthcheck.value.expected_statuses
              host              = http_healthcheck.value.host
              http2             = http_healthcheck.value.http2
              path              = http_healthcheck.value.path
            }
          }

          dynamic "stream_healthcheck" {
            for_each = healthcheck.value.stream_healthcheck != null ? [healthcheck.value.stream_healthcheck] : []
            content {
              receive = stream_healthcheck.value.receive
              send    = stream_healthcheck.value.send
            }
          }
        }
      }

      dynamic "load_balancing_config" {
        for_each = stream_backend.value.load_balancing_config != null ? [stream_backend.value.load_balancing_config] : []
        content {
          locality_aware_routing_percent = load_balancing_config.value.locality_aware_routing_percent
          mode                           = load_balancing_config.value.mode
          panic_threshold                = load_balancing_config.value.panic_threshold
          strict_locality                = load_balancing_config.value.strict_locality
        }
      }

      dynamic "tls" {
        for_each = stream_backend.value.tls != null ? [stream_backend.value.tls] : []
        content {
          sni = tls.value.sni

          dynamic "validation_context" {
            for_each = tls.value.validation_context != null ? [tls.value.validation_context] : []
            content {
              trusted_ca_bytes = validation_context.value.trusted_ca_bytes
              trusted_ca_id    = validation_context.value.trusted_ca_id
            }
          }
        }
      }
    }
  }
}

output "created_at" {
  value = yandex_alb_backend_group.alb_backend_group.created_at
}

output "id" {
  value = yandex_alb_backend_group.alb_backend_group.id
}