variable "service_account_id" {
  type        = string
  description = "https://yandex.cloud/ru/docs/iam/concepts/users/service-accounts"
}

variable "deletion_protection" {
  type    = bool
  default = false
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

variable "max_checking_health_duration" {
  type    = number
  default = null
}

variable "name" {
  type    = string
  default = null
}

variable "variables" {
  type    = map(string)
  default = null
}

variable "allocation_policy" {
  type = object({
    zones = set(string)
    instance_tags_pool = optional(object({
      tags = list(string)
      zone = string
    }))
  })
  validation {
    condition     = alltrue([for zone in var.allocation_policy.zones : contains(["ru-central1-a", "ru-central1-b", "ru-central1-d"], zone)])
    error_message = "Invalid allocation policy zones, valid values: \"ru-central1-a\", \"ru-central1-b\", \"ru-central1-d\""
  }
  validation {
    condition = var.allocation_policy.instance_tags_pool != null ? (
      (var.allocation_policy.instance_tags_pool.tags != null && var.allocation_policy.instance_tags_pool.zone != null) ||
      (var.allocation_policy.instance_tags_pool.tags == null && var.allocation_policy.instance_tags_pool.zone == null)
    ) : true
    error_message = "Allocation policy instance group tags pool requires the following variables to be specified: tags, zone"
  }
}

variable "deploy_policy" {
  type = object({
    max_expansion    = number
    max_unavailable  = number
    max_creating     = optional(number)
    max_deleting     = optional(number)
    startup_duration = optional(number)
    strategy         = optional(string)
  })
  validation {
    condition     = var.deploy_policy.strategy != null ? contains(["proactive", "opportunistic"], var.deploy_policy.strategy) : true
    error_message = "Invalid deploy policy strategy, valid values: \"proactive\" or \"opportunistic\""
  }
}

variable "instance_template" {
  type = object({
    description               = optional(string)
    hostname                  = optional(string)
    labels                    = optional(map(string))
    metadata                  = optional(map(string))
    name                      = optional(string)
    platform_id               = optional(string, "standard-v2")
    reserved_instance_pool_id = optional(string)
    service_account_id        = optional(string)
    boot_disk = object({
      device_name = optional(string)
      disk_id     = optional(string)
      mode        = optional(string)
      name        = optional(string)
      initialize_params = optional(object({
        description = optional(string)
        image_id    = optional(string, "fd8hjrk74m4jvmvl5gi6") # Ubuntu 24.04 LTS
        size        = optional(number, 10)
        snapshot_id = optional(string)
        type        = optional(string, "network-hdd")
      }))
    })
    network_interface = list(object({
      ip_address         = optional(string)
      ipv4               = optional(bool)
      ipv6               = optional(bool)
      ipv6_address       = optional(string)
      nat                = optional(bool, false)
      nat_ip_address     = optional(string)
      network_id         = optional(string)
      security_group_ids = optional(list(string))
      subnet_ids         = optional(set(string))
      dns_record = optional(list(object({
        fqdn        = string
        dns_zone_id = optional(string)
        ptr         = optional(bool)
        ttl         = optional(number)
      })))
      ipv6_dns_record = optional(list(object({
        fqdn        = string
        dns_zone_id = optional(string)
        ptr         = optional(bool)
        ttl         = optional(number)
      })))
      nat_dns_record = optional(list(object({
        fqdn        = string
        dns_zone_id = optional(string)
        ptr         = optional(bool)
        ttl         = optional(number)
      })))
    }))
    resources = object({
      cores         = optional(number, 2)
      memory        = optional(number, 2)
      core_fraction = optional(number, 20)
      gpus          = optional(number)
    })
    filesystem = optional(list(object({
      filesystem_id = optional(string)
      device_name   = optional(string)
      mode          = optional(string)
    })))
    metadata_options = optional(object({
      aws_v1_http_endpoint = optional(number)
      aws_v1_http_token    = optional(number)
      gce_http_endpoint    = optional(number)
      gce_http_token       = optional(number)
    }))
    network_settings = optional(object({
      type = optional(string)
    }))
    placement_policy = optional(object({
      placement_group_id = optional(string)
    }))
    scheduling_policy = optional(object({
      preemptible = optional(bool, true)
    }))
    secondary_disk = optional(list(object({
      device_name = optional(string)
      disk_id     = optional(string)
      mode        = optional(string)
      name        = optional(string)
      initialize_params = optional(object({
        description = optional(string)
        image_id    = optional(string)
        size        = optional(number)
        snapshot_id = optional(string)
        type        = optional(string)
      }))
    })))
  })
  validation {
    condition = var.instance_template.boot_disk.initialize_params != null ? contains(
      ["network-hdd", "network-ssd", "network-ssd-nonreplicated", "network-ssd-io-m3"], var.instance_template.boot_disk.initialize_params.type
    ) : true
    error_message = "Invalid instance template disk type, see description link"
  }
  validation {
    condition     = contains(["standard-v1", "standard-v2", "standard-v3", "amd-v1", "standard-v4a"], var.instance_template.platform_id)
    error_message = "Invalid instance template platform, valid values: \"standard-v1\", \"standard-v2\", \"standard-v3\", \"amd-v1\", \"standard-v4a\""
  }
  validation {
    condition = var.instance_template.boot_disk.initialize_params != null ? (
      (var.instance_template.boot_disk.initialize_params.image_id != null) != (var.instance_template.boot_disk.initialize_params.snapshot_id != null)
    ) : true
    error_message = "For boot disk must specify one of the two, either disk image_id or disk snapshot_id."
  }
  validation {
    condition     = var.instance_template.resources.cores % 2 == 0
    error_message = "Invalid instance template cores count, value must be divisible by 2 without a remainder"
  }
  validation {
    condition     = contains([5, 20, 50, 100], var.instance_template.resources.core_fraction)
    error_message = "Invalid instance template core fraction, valid values: 5, 20, 50, 100"
  }
  validation {
    condition     = var.instance_template.metadata_options != null ? contains([0, 1, 2], var.instance_template.metadata_options.aws_v1_http_endpoint) : true
    error_message = "invalid value for aws_v1_http_endpoint, valid values: 0, 1, 2"
  }
  validation {
    condition     = var.instance_template.metadata_options != null ? contains([0, 1, 2], var.instance_template.metadata_options.aws_v1_http_token) : true
    error_message = "invalid value for aws_v1_http_endpoint, valid values: 0, 1, 2"
  }
  validation {
    condition     = var.instance_template.metadata_options != null ? contains([0, 1, 2], var.instance_template.metadata_options.gce_http_endpoint) : true
    error_message = "invalid value for aws_v1_http_endpoint, valid values: 0, 1, 2"
  }
  validation {
    condition     = var.instance_template.metadata_options != null ? contains([0, 1, 2], var.instance_template.metadata_options.gce_http_token) : true
    error_message = "invalid value for aws_v1_http_endpoint, valid values: 0, 1, 2"
  }
  validation {
    condition = var.instance_template.secondary_disk != null ? var.instance_template.secondary_disk.initialize_params != null ? (
      (var.instance_template.secondary_disk.initialize_params.image_id != null) !=
      (var.instance_template.secondary_disk.initialize_params.snapshot_id != null)
    ) : true : true
    error_message = "For second boot disk must specify one of the two, either disk image_id or disk snapshot_id."
  }
  description = "https://yandex.cloud/ru/docs/compute/concepts/instance-groups/instance-template"
}

variable "scale_policy" {
  type = object({
    auto_scale = optional(object({
      initial_size           = number
      measurement_duration   = number
      auto_scale_type        = optional(string)
      cpu_utilization_target = optional(number)
      max_size               = optional(number)
      min_zone_size          = optional(number)
      stabilization_duration = optional(number)
      warmup_duration        = optional(number)
      custom_rule = optional(list(object({
        metric_name = string
        metric_type = string
        rule_type   = string
        target      = number
        folder_id   = optional(string)
        labels      = optional(map(string))
        service     = optional(string)
      })))
    }))
    fixed_scale = optional(object({
      size = optional(number)
    }))
    test_auto_scale = optional(bool)
  })
  validation {
    condition = var.scale_policy.auto_scale != null ? (
      (var.scale_policy.auto_scale.initial_size != null && var.scale_policy.auto_scale.measurement_duration != null) ||
      (var.scale_policy.auto_scale.initial_size == null && var.scale_policy.auto_scale.measurement_duration == null)
    ) : true
    error_message = "Instance group autoscaling policy requires the following variables to be specified: initial_size, measurement_duration"
  }
  validation {
    condition     = var.scale_policy.auto_scale != null ? contains(["ZONAL", "REGIONAL"], var.scale_policy.auto_scale.auto_scale_type) : true
    error_message = "Invalid instance group autoscaling type in scale policy, valid values: \"ZONAL\", \"REGIONAL\""
  }
  validation {
    condition = var.scale_policy.auto_scale != null ? var.scale_policy.auto_scale.custom_rule != null ? contains(
      ["GAUGE", "COUNTER"], var.scale_policy.auto_scale.custom_rule.metric_type
    ) : true : true
    error_message = "Invalid metric type in instance group autoscaling policy, valid values: \"GAUGE\", \"COUNTER\""
  }
  validation {
    condition = var.scale_policy.auto_scale != null ? var.scale_policy.auto_scale.custom_rule != null ? contains(
      ["UTILIZATION", "WORKLOAD"], var.scale_policy.auto_scale.custom_rule.rule_type
    ) : true : true
    error_message = "Invalid rule type in instance group autoscaling policy, valid values: \"UTILIZATION\", \"WORKLOAD\""
  }
  validation {
    condition = var.scale_policy.auto_scale != null ? var.scale_policy.auto_scale.custom_rule != null ? (
      (var.scale_policy.auto_scale.custom_rule.metric_name != null && var.scale_policy.auto_scale.custom_rule.metric_type != null &&
      var.scale_policy.auto_scale.custom_rule.rule_type != null && var.scale_policy.auto_scale.custom_rule.target != null) ||
      (var.scale_policy.auto_scale.custom_rule.metric_name == null && var.scale_policy.auto_scale.custom_rule.metric_type == null &&
      var.scale_policy.auto_scale.custom_rule.rule_type == null && var.scale_policy.auto_scale.custom_rule.target == null)
    ) : true : true
    error_message = "Instance group custom autoscaling policy rule requires the following variables to be specified: metric_name, metric_type, rule_type, target"
  }
  validation {
    condition     = var.scale_policy.test_auto_scale != null ? var.scale_policy.test_auto_scale ? var.scale_policy.fixed_scale.size != null : true : true
    error_message = "To test autoscaling instance group need to specify the size fo fixed scale"
  }
}

variable "application_load_balancer" {
  type = object({
    ignore_health_checks         = optional(bool)
    max_opening_traffic_duration = optional(number)
    target_group_description     = optional(string)
    target_group_labels          = optional(map(string))
    target_group_name            = optional(string)
  })
  default = null
}

variable "health_check" {
  type = object({
    healthy_threshold   = optional(number)
    interval            = optional(number)
    timeout             = optional(number)
    unhealthy_threshold = optional(number)
    http_options = optional(object({
      path = string
      port = number
    }))
    tcp_options = optional(object({
      port = number
    }))
  })
  default = null
}

variable "load_balancer" {
  type = object({
    ignore_health_checks         = optional(bool)
    max_opening_traffic_duration = optional(number)
    target_group_description     = optional(string)
    target_group_labels          = optional(map(string))
    target_group_name            = optional(string)
  })
  default = null
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    update = optional(string)
  })
  default = null
}

