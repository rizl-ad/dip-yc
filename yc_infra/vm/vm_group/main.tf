resource "yandex_compute_instance_group" "vm_group" {
  service_account_id = var.service_account_id
  deletion_protection = var.deletion_protection
  description = var.description
  folder_id = var.folder_id
  labels = var.labels
  max_checking_health_duration = var.max_checking_health_duration
  name = var.name
  variables = var.variables
  
  allocation_policy {
    zones = var.allocation_policy.zones

    dynamic "instance_tags_pool" {
      for_each = var.allocation_policy.instance_tags_pool != null ? [var.allocation_policy.instance_tags_pool] : []
      content {
        tags = instance_tags_pool.value.tags
        zone = instance_tags_pool.value.zone
      }
    }
  }

  deploy_policy {
    max_expansion = var.deploy_policy.max_expansion
    max_unavailable = var.deploy_policy.max_unavailable
    max_creating = var.deploy_policy.max_creating
    max_deleting = var.deploy_policy.max_deleting
    startup_duration = var.deploy_policy.startup_duration
    strategy = var.deploy_policy.strategy
  }

  instance_template {
    description = var.instance_template.description
    hostname = var.instance_template.hostname != null ? "${var.instance_template.hostname}-{instance.index}" : null
    labels = var.instance_template.labels
    metadata = var.instance_template.metadata
    name = var.name != null ? "${var.name}-{instance.index}" : null 
    platform_id = var.instance_template.platform_id
    reserved_instance_pool_id = var.instance_template.reserved_instance_pool_id
    service_account_id = var.instance_template.service_account_id

    boot_disk {
      device_name = var.instance_template.boot_disk.device_name
      disk_id = var.instance_template.boot_disk.disk_id
      mode = var.instance_template.boot_disk.mode
      name = var.instance_template.boot_disk.name
      
      initialize_params {
        description = var.instance_template.boot_disk.initialize_params.description
        image_id = var.instance_template.boot_disk.initialize_params.image_id
        size = var.instance_template.boot_disk.initialize_params.size
        snapshot_id = var.instance_template.boot_disk.initialize_params.snapshot_id
        type = var.instance_template.boot_disk.initialize_params.type
      }
    }

    dynamic "network_interface" {
      for_each = var.instance_template.network_interface != null ? var.instance_template.network_interface : []
      content {
        ip_address = network_interface.value.ip_address
        ipv4 = network_interface.value.ipv4
        ipv6 = network_interface.value.ipv6
        ipv6_address = network_interface.value.ipv6_address
        nat = network_interface.value.nat
        nat_ip_address = network_interface.value.nat_ip_address
        network_id = network_interface.value.network_id
        security_group_ids = network_interface.value.security_group_ids
        subnet_ids = network_interface.value.subnet_ids

        dynamic "dns_record" {
          for_each = network_interface.value.dns_record != null ? network_interface.value.dns_record : []
          content {
            fqdn = dns_record.value.fqdn
            dns_zone_id = dns_record.value.dns_zone_id
            ptr = dns_record.value.ptr
            ttl = dns_record.value.ttl
          }
        }

        dynamic "ipv6_dns_record" {
          for_each = network_interface.value.ipv6_dns_record != null ? network_interface.value.ipv6_dns_record : []
          content {
            fqdn = ipv6_dns_record.value.fqdn
            dns_zone_id = ipv6_dns_record.value.dns_zone_id
            ptr = ipv6_dns_record.value.ptr
            ttl = ipv6_dns_record.value.ttl
          }
        }

        dynamic "nat_dns_record" {
          for_each = network_interface.value.nat_dns_record != null ? network_interface.value.nat_dns_record : []
          content {
            fqdn = nat_dns_record.value.fqdn
            dns_zone_id = nat_dns_record.value.dns_zone_id
            ptr = nat_dns_record.value.ptr
            ttl = nat_dns_record.value.ttl
          }
        }
      }
    }

    resources {
      cores = var.instance_template.resources.cores
      memory = var.instance_template.resources.memory
      core_fraction = var.instance_template.resources.core_fraction
      gpus = var.instance_template.resources.gpus
    }

    dynamic "filesystem" {
      for_each = var.instance_template.filesystem != null ? var.instance_template.filesystem : []
      content {
        filesystem_id = filesystem.value.filesystem_id
        device_name = filesystem.value.device_name
        mode = filesystem.value.mode
      }
    }

    dynamic "metadata_options" {
      for_each = var.instance_template.metadata_options != null ? [var.instance_template.metadata_options] : []
      content {
        aws_v1_http_endpoint = metadata_options.value.aws_v1_http_endpoint
        aws_v1_http_token = metadata_options.value.aws_v1_http_token
        gce_http_endpoint = metadata_options.value.gce_http_endpoint
        gce_http_token = metadata_options.value.gce_http_token
      }
    }

    dynamic "network_settings" {
      for_each = var.instance_template.network_settings != null ? [var.instance_template.network_settings] : []
      content {
        type = network_settings.value.type
      }
    }

    dynamic "placement_policy" {
      for_each = var.instance_template.placement_policy != null ? [var.instance_template.placement_policy] : []
      content {
        placement_group_id = placement_policy.value.placement_group_id
      }
    }

    dynamic "scheduling_policy" {
      for_each = var.instance_template.scheduling_policy != null ? [var.instance_template.scheduling_policy] : []
      content {
        preemptible = scheduling_policy.value.preemptible
      }
    }

    dynamic "secondary_disk" {
      for_each = var.instance_template.secondary_disk != null ? var.instance_template.secondary_disk : []
      content {
        device_name = secondary_disk.value.device_name
        disk_id = secondary_disk.value.disk_id
        mode = secondary_disk.value.mode
        name = secondary_disk.value.name
        
        initialize_params {
          description = secondary_disk.value.initialize_params.description
          image_id = secondary_disk.value.initialize_params.image_id
          size = secondary_disk.value.initialize_params.size
          snapshot_id = secondary_disk.value.initialize_params.snapshot_id
          type = secondary_disk.value.initialize_params.type
        }
      }
    }
  }

  scale_policy {
    
    dynamic "auto_scale" {
      for_each = var.scale_policy.auto_scale != null ? [var.scale_policy.auto_scale] : []
      content {
        initial_size = auto_scale.value.initial_size
        measurement_duration = auto_scale.value.measurement_duration
        auto_scale_type = auto_scale.value.auto_scale_type
        cpu_utilization_target = auto_scale.value.cpu_utilization_target
        max_size = auto_scale.value.max_size
        min_zone_size = auto_scale.value.min_zone_size
        stabilization_duration = auto_scale.value.stabilization_duration
        warmup_duration = auto_scale.value.warmup_duration
        
        dynamic "custom_rule" {
          for_each = auto_scale.value.custom_rule != null ? auto_scale.value.custom_rule : []
          content {
            metric_name = custom_rule.value.metric_name
            metric_type = custom_rule.value.metric_type
            rule_type = custom_rule.value.rule_type
            target = custom_rule.value.target
            folder_id = custom_rule.value.folder_id
            labels = custom_rule.value.labels
            service = custom_rule.value.service
          }
        }
      }
    }

    dynamic "fixed_scale" {
      for_each = var.scale_policy.fixed_scale != null ? [var.scale_policy.fixed_scale] : []
      content {
        size = fixed_scale.value.size
      }
    }

    dynamic "test_auto_scale" {
      for_each = var.scale_policy.test_auto_scale != null ? [var.scale_policy.test_auto_scale] : []
      content {
        initial_size = test_auto_scale.value.initial_size
        measurement_duration = test_auto_scale.value.measurement_duration
        auto_scale_type = test_auto_scale.value.auto_scale_type
        cpu_utilization_target = test_auto_scale.value.cpu_utilization_target
        max_size = test_auto_scale.value.max_size
        min_zone_size = test_auto_scale.value.min_zone_size
        stabilization_duration = test_auto_scale.value.stabilization_duration
        warmup_duration = test_auto_scale.value.warmup_duration
        
        dynamic "custom_rule" {
          for_each = test_auto_scale.value.custom_rule != null ? test_auto_scale.value.custom_rule : []
          content {
            metric_name = custom_rule.value.metric_name
            metric_type = custom_rule.value.metric_type
            rule_type = custom_rule.value.rule_type
            target = custom_rule.value.target
            folder_id = custom_rule.value.folder_id
            labels = custom_rule.value.labels
            service = custom_rule.value.service
          }
        }
      }
    }
  }

  dynamic "application_load_balancer" {
    for_each = var.application_load_balancer != null ? [var.application_load_balancer] : []
    content {
      ignore_health_checks = application_load_balancer.value.ignore_health_checks
      max_opening_traffic_duration = application_load_balancer.value.max_opening_traffic_duration
      target_group_description = application_load_balancer.value.target_group_description
      target_group_labels = application_load_balancer.value.target_group_labels
      target_group_name = application_load_balancer.value.target_group_name
    }
  }

  dynamic "health_check" {
    for_each = var.health_check != null ?  [var.health_check] : []
    content {
      healthy_threshold = health_check.value.healthy_threshold
      interval = health_check.value.interval
      timeout = health_check.value.timeout
      unhealthy_threshold = health_check.value.unhealthy_threshold

      dynamic "http_options" {
        for_each = health_check.value.http_options != null ? [health_check.value.http_options] : []
        content {
          path = http_options.value.path
          port = http_options.value.port
        }
      }

      dynamic "tcp_options" {
        for_each = health_check.value.tcp_options != null ? [health_check.value.tcp_options] : []
        content {
          port = tcp_options.value.port
        }
      }

    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer != null ? [var.load_balancer] : []
    content {
      ignore_health_checks = load_balancer.value.ignore_health_checks
      max_opening_traffic_duration = load_balancer.value.max_opening_traffic_duration
      target_group_description = load_balancer.value.target_group_description
      target_group_labels = load_balancer.value.target_group_labels
      target_group_name = load_balancer.value.target_group_name
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      update = timeouts.value.update
    }
  }

}

output "created_at" {
  value = yandex_compute_instance_group.vm_group.created_at
}

output "id" {
  value = yandex_compute_instance_group.vm_group.id
}

output "instances" {
  value = yandex_compute_instance_group.vm_group.instances
}

output "status" {
  value = yandex_compute_instance_group.vm_group.status
}

output "application_load_balancer_status_message" {
  value = yandex_compute_instance_group.vm_group.application_load_balancer[*].status_message
}

output "application_load_balancer_target_group_id" {
  value = yandex_compute_instance_group.vm_group.application_load_balancer[*].target_group_id
}

output "load_balancer_status_message" {
  value = yandex_compute_instance_group.vm_group.load_balancer[*].status_message
}

output "load_balancer_target_group_id" {
  value = yandex_compute_instance_group.vm_group.load_balancer[*].target_group_id
}

output "instance_inventory_data" {
  value = [ for instance in yandex_compute_instance_group.vm_group.instances : {
    name = instance.name
    labels = yandex_compute_instance_group.vm_group.instance_template[0].labels
    ip = instance.network_interface[0].nat_ip_address == null || instance.network_interface[0].nat_ip_address == "" ? (
      instance.network_interface[0].ip_address 
    ) : (
      instance.network_interface[0].nat_ip_address
    )
  }]
}