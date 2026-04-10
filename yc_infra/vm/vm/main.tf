resource "yandex_compute_instance" "vm" {
  allow_recreate            = var.allow_recreate
  allow_stopping_for_update = var.allow_stopping_for_update
  description               = var.description
  folder_id                 = var.folder_id
  gpu_cluster_id            = var.gpu_cluster_id
  hostname                  = var.hostname
  labels                    = var.labels
  maintenance_grace_period  = var.maintenance_grace_period
  maintenance_policy        = var.maintenance_policy
  metadata                  = var.metadata
  name                      = var.name
  network_acceleration_type = var.network_acceleration_type
  platform_id               = var.platform_id
  service_account_id        = var.service_account_id
  zone                      = var.zone

  dynamic "boot_disk" {
    for_each = var.boot_disk != null ? [var.boot_disk] : []
    content {
      auto_delete = boot_disk.value.auto_delete
      device_name = boot_disk.value.device_name
      disk_id     = boot_disk.value.disk_id
      mode        = boot_disk.value.mode

      dynamic "initialize_params" {
        for_each = boot_disk.value.initialize_params != null ? [boot_disk.value.initialize_params] : []
        content {
          block_size  = initialize_params.value.block_size
          description = initialize_params.value.description
          image_id    = initialize_params.value.image_id
          kms_key_id  = initialize_params.value.kms_key_id
          name        = initialize_params.value.name
          size        = initialize_params.value.size
          snapshot_id = initialize_params.value.snapshot_id
          type        = initialize_params.value.type
        }
      }
    }
  }

  dynamic "filesystem" {
    for_each = var.filesystem != null ? var.filesystem : []
    content {
      device_name   = filesystem.value.device_name
      filesystem_id = filesystem.value.filesystem_id
      mode          = filesystem.value.mode
    }
  }

  dynamic "local_disk" {
    for_each = var.local_disk != null ? var.local_disk : []
    content {
      device_name = local_disk.value.device_name
      size_bytes  = local_disk.value.size_bytes
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []
    content {
      aws_v1_http_endpoint = metadata_options.value.aws_v1_http_endpoint
      aws_v1_http_token    = metadata_options.value.aws_v1_http_token
      gce_http_endpoint    = metadata_options.value.gce_http_endpoint
      gce_http_token       = metadata_options.value.gce_http_token
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interface != null ? var.network_interface : []
    content {
      index              = network_interface.value.index
      ip_address         = network_interface.value.ip_address
      ipv4               = network_interface.value.ipv4
      ipv6               = network_interface.value.ipv6
      ipv6_address       = network_interface.value.ipv6_address
      nat                = network_interface.value.nat
      nat_ip_address     = network_interface.value.nat_ip_address
      security_group_ids = network_interface.value.security_group_ids
      subnet_id          = network_interface.value.subnet_id

      dynamic "dns_record" {
        for_each = network_interface.value.dns_record != null ? network_interface.value.dns_record : []
        content {
          dns_zone_id = dns_record.value.dns_zone_id
          fqdn        = dns_record.value.fqdn
          ptr         = dns_record.value.ptr
          ttl         = dns_record.value.ttl
        }
      }

      dynamic "ipv6_dns_record" {
        for_each = network_interface.value.ipv6_dns_record != null ? network_interface.value.ipv6_dns_record : []
        content {
          dns_zone_id = ipv6_dns_record.value.dns_zone_id
          fqdn        = ipv6_dns_record.value.fqdn
          ptr         = ipv6_dns_record.value.ptr
          ttl         = ipv6_dns_record.value.ttl
        }
      }

      dynamic "nat_dns_record" {
        for_each = network_interface.value.nat_dns_record != null ? network_interface.value.nat_dns_record : []
        content {
          dns_zone_id = nat_dns_record.value.dns_zone_id
          fqdn        = nat_dns_record.value.fqdn
          ptr         = nat_dns_record.value.ptr
          ttl         = nat_dns_record.value.ttl
        }
      }
    }
  }

  dynamic "placement_policy" {
    for_each = var.placement_policy != null ? [var.placement_policy] : []
    content {
      placement_group_id        = placement_policy.value.placement_group_id
      placement_group_partition = placement_policy.value.placement_group_partition

      dynamic "host_affinity_rules" {
        for_each = placement_policy.value.host_affinity_rules != null ? placement_policy.value.host_affinity_rules : []
        content {
          key    = host_affinity_rules.value.key
          op     = host_affinity_rules.value.op
          values = host_affinity_rules.value.values
        }
      }
    }
  }

  dynamic "resources" {
    for_each = var.resources != null ? [var.resources] : []
    content {
      core_fraction = resources.value.core_fraction
      cores         = resources.value.cores
      gpus          = resources.value.gpus
      memory        = resources.value.memory
    }
  }

  dynamic "scheduling_policy" {
    for_each = var.scheduling_policy != null ? [var.scheduling_policy] : []
    content {
      preemptible = scheduling_policy.value.preemptible
    }
  }

  dynamic "secondary_disk" {
    for_each = var.secondary_disk != null ? var.secondary_disk : []
    content {
      auto_delete = secondary_disk.value.auto_delete
      device_name = secondary_disk.value.device_name
      disk_id     = secondary_disk.value.disk_id
      mode        = secondary_disk.value.mode
    }
  }
}

output "created_at" {
  value = yandex_compute_instance.vm.created_at
}

output "fqdn" {
  value = yandex_compute_instance.vm.fqdn
}

output "hardware_generation" {
  value = yandex_compute_instance.vm.hardware_generation
}

output "id" {
  value = yandex_compute_instance.vm.id
}

output "status" {
  value = yandex_compute_instance.vm.status
}

output "local_disk_device_name" {
  value = yandex_compute_instance.vm.local_disk[*].device_name
}

output "network_interface_mac_address" {
  value = yandex_compute_instance.vm.network_interface[*].mac_address
}

output "network_interface_nat_ip_version" {
  value = yandex_compute_instance.vm.network_interface[*].nat_ip_version
}

output "network_interface_ip_address" {
  value = yandex_compute_instance.vm.network_interface[*].nat_ip_address != null ? (
    yandex_compute_instance.vm.network_interface[*].nat_ip_address
    ) : (
    yandex_compute_instance.vm.network_interface[*].ip_address
  )
}

output "instance_inventory_data" {
  value = {
    name   = yandex_compute_instance.vm.name
    labels = yandex_compute_instance.vm.labels
    ip = yandex_compute_instance.vm.network_interface[0].nat_ip_address != null ? (
      yandex_compute_instance.vm.network_interface[0].nat_ip_address
      ) : (
      yandex_compute_instance.vm.network_interface[0].ip_address
    )
  }
}
