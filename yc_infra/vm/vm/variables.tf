variable "allow_recreate" {
  type    = bool
  default = null
}

variable "allow_stopping_for_update" {
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

variable "gpu_cluster_id" {
  type    = string
  default = null
}

variable "hostname" {
  type    = string
  default = null
}

variable "labels" {
  type    = map(string)
  default = null
}

variable "maintenance_grace_period" {
  type    = string
  default = null
}

variable "maintenance_policy" {
  type    = string
  default = "unspecified"
  validation {
    condition     = var.maintenance_policy != null ? contains(["unspecified", "migrate", "restart"], var.maintenance_policy) : true
    error_message = "Invalid instance maintenance policy, valid values: \"unspecified\", \"migrate\", \"restart\""
  }
  description = "https://yandex.cloud/ru/docs/compute/concepts/maintenance-policies"
}

variable "metadata" {
  type    = map(string)
  default = null
}

variable "name" {
  type = string
}

variable "network_acceleration_type" {
  type    = string
  default = "standard"
  validation {
    condition     = var.network_acceleration_type != null ? contains(["standard", "software_accelerated"], var.network_acceleration_type) : true
    error_message = "Invalid instance network acceleration type, valid values: \"standard\", \"software_accelerated\""
  }
  description = "https://yandex.cloud/ru/docs/compute/concepts/software-accelerated-network"
}

variable "platform_id" {
  type    = string
  default = "standard-v2"
  validation {
    condition     = contains(["standard-v1", "standard-v2", "standard-v3", "amd-v1", "standard-v4a"], var.platform_id)
    error_message = "Invalid instance platform id, valid values: \"standard-v1\", \"standard-v2\", \"standard-v3\", \"amd-v1\", \"standard-v4a\""
  }
  description = "https://yandex.cloud/ru/docs/compute/concepts/vm-platforms"
}

variable "service_account_id" {
  type    = string
  default = null
}

variable "zone" {
  type    = string
  default = "ru-central1-a"
  validation {
    condition     = contains(["ru-central1-a", "ru-central1-b", "ru-central1-d"], var.zone)
    error_message = "Invalid zones, valid values: \"ru-central1-a\", \"ru-central1-b\", \"ru-central1-d\""
  }
}

variable "boot_disk" {
  type = object({
    auto_delete = optional(bool)
    device_name = optional(string)
    disk_id     = optional(string)
    mode        = optional(string)

    initialize_params = optional(object({
      block_size  = optional(number)
      description = optional(string)
      image_id    = optional(string, "fd8hjrk74m4jvmvl5gi6") # Ubuntu 24.04 LTS
      kms_key_id  = optional(string)
      name        = optional(string)
      size        = optional(number, 10)
      snapshot_id = optional(string)
      type        = optional(string, "network-hdd")
    }))
  })
  default = {
    initialize_params = {}
  }
  validation {
    condition = contains(
      ["network-hdd", "network-ssd", "network-ssd-nonreplicated", "network-ssd-io-m3"], var.boot_disk.initialize_params.type
    )
    error_message = "Invalid instance disk type, see https://yandex.cloud/ru/docs/compute/concepts/disk"
  }
  description = "https://yandex.cloud/ru/docs/compute/concepts/disk"
}

variable "filesystem" {
  type = list(object({
    device_name   = optional(string)
    filesystem_id = string
    mode          = optional(string)
  }))
  default = null
}

variable "local_disk" {
  type = list(object({
    device_name = optional(string)
    size_bytes  = number # specified in bytes
  }))
  default = null
}

variable "metadata_options" {
  type = object({
    aws_v1_http_endpoint = optional(number)
    aws_v1_http_token    = optional(number)
    gce_http_endpoint    = optional(number)
    gce_http_token       = optional(number)
  })
  default     = null
  description = "https://yandex.cloud/ru/docs/compute/concepts/vm-metadata"
}

variable "network_interface" {
  type = list(object({
    index              = optional(number)
    ip_address         = optional(string)
    ipv4               = optional(bool)
    ipv6               = optional(bool)
    ipv6_address       = optional(string)
    nat                = optional(bool)
    nat_ip_address     = optional(string)
    security_group_ids = optional(set(string))
    subnet_id          = string

    dns_record = optional(list(object({
      dns_zone_id = optional(string)
      fqdn        = string
      ptr         = optional(bool)
      ttl         = optional(number)
    })))

    ipv6_dns_record = optional(list(object({
      dns_zone_id = optional(string)
      fqdn        = string
      ptr         = optional(bool)
      ttl         = optional(number)
    })))

    nat_dns_record = optional(list(object({
      dns_zone_id = optional(string)
      fqdn        = string
      ptr         = optional(bool)
      ttl         = optional(number)
    })))
  }))
  description = "https://yandex.cloud/ru/docs/compute/concepts/network"
}

variable "placement_policy" {
  type = object({
    placement_group_id        = optional(string)
    placement_group_partition = optional(number)

    host_affinity_rules = optional(list(object({
      key    = optional(string)
      op     = optional(string)
      values = optional(list(string))
    })))
  })
  default = null
}

variable "resources" {
  type = object({
    core_fraction = optional(number, 20)
    cores         = optional(number, 2)
    gpus          = optional(number)
    memory        = optional(number, 2)
  })
  default = {}
  validation {
    condition     = contains([5, 20, 50, 100], var.resources.core_fraction)
    error_message = "Invalid instance core fraction, valid values: 5, 20, 50, 100"
  }
  validation {
    condition     = var.resources.cores % 2 == 0
    error_message = "Invalid instance cores count, value must be divisible by 2 without a remainder"
  }
  description = "https://yandex.cloud/ru/docs/compute/concepts/performance-levels"
}

variable "scheduling_policy" {
  type = object({
    preemptible = optional(bool, true)
  })
  default     = {}
  description = "https://yandex.cloud/ru/docs/compute/concepts/preemptible-vm"
}

variable "secondary_disk" {
  type = list(object({
    auto_delete = optional(bool)
    device_name = optional(string)
    disk_id     = string
    mode        = optional(string)
  }))
  default = null
}