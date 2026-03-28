resource "yandex_alb_load_balancer" "lb_app" {
  allow_zonal_shift = var.allow_zonal_shift
  description = var.description
  folder_id = var.folder_id
  labels = var.labels
  name = var.name
  network_id = var.network_id
  region_id = var.region_id
  security_group_ids = var.security_group_ids

  dynamic "allocation_policy" {
    for_each = var.allocation_policy != null ? [var.allocation_policy] : []
    content {
      dynamic "location" {
        for_each = allocation_policy.value.location != null ? allocation_policy.value.location : []
        content {
          disable_traffic = location.value.disable_traffic
          subnet_id = location.value.subnet_id
          zone_id = location.value.zone_id
        }
      }
    }
  }

  dynamic "auto_scale_policy" {
    for_each = var.auto_scale_policy != null ? [var.auto_scale_policy] : []
    content {
      max_size = auto_scale_policy.value.max_size
      min_zone_size = auto_scale_policy.value.min_zone_size
    }
  }

  dynamic "listener" {
    for_each = var.listener != null ? var.listener : []
    content {
      name = listener.value.name

      endpoint {
        ports = listener.value.endpoint.ports

        dynamic "address" {
          for_each = listener.value.endpoint.address != null ? [listener.value.endpoint.address] : []
          content {
            
            dynamic "external_ipv4_address" {
              for_each = address.value.external_ipv4_address != null ? [address.value.external_ipv4_address] : []
              content {
                address = external_ipv4_address.value.address
              }
            }

            dynamic "external_ipv6_address" {
              for_each = address.value.external_ipv6_address != null ? [address.value.external_ipv6_address] : []
              content {
                address = external_ipv6_address.value.address
              }
            }

            dynamic "internal_ipv4_address" {
              for_each = address.value.internal_ipv4_address != null ? [address.value.internal_ipv4_address] : []
              content {
                address = internal_ipv4_address.value.address
                subnet_id = internal_ipv4_address.value.subnet_id
              }
            }
          }
        }
      }

      dynamic "http" {
        for_each = listener.value.http != null ? [listener.value.http] : []
        content {
          dynamic "handler" {
            for_each = http.value.handler != null ? [http.value.handler] : []
            content {
              allow_http10 = handler.value.allow_http10
              http_router_id = handler.value.http_router_id
              rewrite_request_id = handler.value.rewrite_request_id

              dynamic "http2_options" {
                for_each = handler.value.http2_options != null ? [handler.value.http2_options] : []
                content {
                   max_concurrent_streams = http2_options.value.max_concurrent_streams
                }
              }
            }
          }

          dynamic "redirects" {
            for_each = http.value.redirects != null ? [http.value.redirects] : []
            content {
              http_to_https = redirects.value.http_to_https
            }
          }
        }
      }

      dynamic "stream" {
        for_each = listener.value.stream != null ? [listener.value.stream] : []
        content {
          dynamic "handler" {
            for_each = stream.value.handler != null ? [stream.value.handler] : []
            content {
              backend_group_id = handler.value.backend_group_id
              idle_timeout = handler.value.idle_timeout
            }
          }
        }
      }

      dynamic "tls" {
        for_each = listener.value.tls != null ? [listener.value.tls] : []
        content {
          dynamic "default_handler" {
            for_each = tls.value.default_handler != null ? [tls.value.default_handler] : []
            content {
              certificate_ids = default_handler.value.certificate_ids

              dynamic "http_handler" {
                for_each = default_handler.value.http_handler != null ? [default_handler.value.http_handler] : []
                content {
                  allow_http10 = http_handler.value.allow_http10
                  http_router_id = http_handler.value.http_router_id
                  rewrite_request_id = http_handler.value.rewrite_request_id

                  dynamic "http2_options" {
                    for_each = http_handler.value.http2_options != null ? [http_handler.value.http2_options] : []
                    content {
                      max_concurrent_streams = http2_options.value.max_concurrent_streams
                    }
                  }
                }
              }

              dynamic "stream_handler" {
                for_each = default_handler.value.stream_handler != null ? [default_handler.value.stream_handler] : []
                content {
                  backend_group_id = stream_handler.value.backend_group_id
                  idle_timeout = stream_handler.value.idle_timeout
                }
              }
            }
          }

          dynamic "sni_handler" {
            for_each = tls.value.sni_handler != null ? tls.value.sni_handler : []
            content {
              name = sni_handler.value.name
              server_names = sni_handler.value.server_names

              dynamic "handler" {
                for_each = sni_handler.value.handler != null ? [sni_handler.value.handler] : []
                content {
                  certificate_ids = handler.value.certificate_ids

                  dynamic "http_handler" {
                    for_each = handler.value.http_handler != null ? [handler.value.http_handler] : []
                    content {
                      allow_http10 = http_handler.value.allow_http10
                      http_router_id = http_handler.value.http_router_id
                      rewrite_request_id = http_handler.value.rewrite_request_id

                      dynamic "http2_options" {
                        for_each = http_handler.value.http2_options != null ? [http_handler.value.http2_options] : []
                        content {
                          max_concurrent_streams = http2_options.value.max_concurrent_streams
                        }
                      }
                    }
                  }

                  dynamic "stream_handler" {
                    for_each = handler.value.stream_handler != null ? [handler.value.stream_handler] : []
                    content {
                      backend_group_id = stream_handler.value.backend_group_id
                      idle_timeout = stream_handler.value.idle_timeout
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "log_options" {
    for_each = var.log_options != null ? [var.log_options] : []
    content {
      disable = log_options.value.disable
      log_group_id = log_options.value.log_group_id

      dynamic "discard_rule" {
        for_each = log_options.value.discard_rule != null ? log_options.value.discard_rule : []
        content {
          discard_percent = discard_rule.value.discard_percent
          grpc_codes = discard_rule.value.grpc_codes
          http_code_intervals = discard_rule.value.http_code_intervals
          http_codes = discard_rule.value.http_codes
        }
      }
    }
  }
}

output "created_at" {
  value = yandex_alb_load_balancer.lb_app.created_at
}

output "id" {
  value = yandex_alb_load_balancer.lb_app.id
}

output "log_group_id" {
  value = yandex_alb_load_balancer.lb_app.log_group_id
}

output "status" {
  value = yandex_alb_load_balancer.lb_app.status
}

output "listeners" {
  value = yandex_alb_load_balancer.lb_app.listener[*]
}

# output "external_ipv4_address" {
#   value = yandex_alb_load_balancer.lb_app.listener[*].endpoint.address[*].external_ipv4_address.address
# }

# output "external_ipv6_address" {
#   value = yandex_alb_load_balancer.lb_app.listener[*].endpoint.address[*].external_ipv6_address.address
# }

# output "internal_ipv4_address" {
#   value = yandex_alb_load_balancer.lb_app.listener[*].endpoint.address[*].internal_ipv4_address.address
# }

