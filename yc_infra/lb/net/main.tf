resource "yandex_lb_network_load_balancer" "lb_network" {
  allow_zonal_shift   = var.allow_zonal_shift
  deletion_protection = var.deletion_protection
  description         = var.description
  folder_id           = var.folder_id
  labels              = var.labels
  name                = var.name
  region_id           = var.region_id
  type                = var.type

  dynamic "attached_target_group" {
    for_each = var.attached_target_group != null ? [1] : []
    content {
      target_group_id = var.attached_target_group.target_group_id

      dynamic "healthcheck" {
        for_each = var.attached_target_group.healthcheck != null ? [1] : []
        content {
          healthy_threshold   = var.attached_target_group.healthcheck.healthy_threshold
          interval            = var.attached_target_group.healthcheck.interval
          name                = var.attached_target_group.healthcheck.name
          timeout             = var.attached_target_group.healthcheck.timeout
          unhealthy_threshold = var.attached_target_group.healthcheck.unhealthy_threshold

          dynamic "http_options" {
            for_each = var.attached_target_group.healthcheck.http_options != null ? [1] : []
            content {
              path = var.attached_target_group.healthcheck.http_options.path
              port = var.attached_target_group.healthcheck.http_options.port
            }
          }

          dynamic "tcp_options" {
            for_each = var.attached_target_group.healthcheck.tcp_options != null ? [1] : []
            content {
              port = var.attached_target_group.healthcheck.tcp_options.port
            }
          }
        }
      }
    }
  }

  listener {
    name        = var.listener.name
    port        = var.listener.port
    protocol    = var.listener.protocol
    target_port = var.listener.target_port

    dynamic "external_address_spec" {
      for_each = var.listener.external_address_spec != null ? [1] : []
      content {
        address    = var.listener.external_address_spec.address
        ip_version = var.listener.external_address_spec.ip_version
      }
    }

    dynamic "internal_address_spec" {
      for_each = var.listener.internal_address_spec != null ? [1] : []
      content {
        address    = var.listener.internal_address_spec.address
        ip_version = var.listener.internal_address_spec.ip_version
        subnet_id  = var.listener.internal_address_spec.subnet_id
      }
    }
  }
}

output "created_at" {
  value = yandex_lb_network_load_balancer.lb_network.created_at
}

output "id" {
  value = yandex_lb_network_load_balancer.lb_network.id
}

output "listener_data" {
  value = [for listener in yandex_lb_network_load_balancer.lb_network.listener : var.listener.external_address_spec != null ? {
    name = listener.name
    ip   = listener.external_address_spec[*].address
    } : {
    name = listener.name
    ip   = listener.internal_address_spec[*].address
  }]
}
