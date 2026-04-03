variable "vm_user_name" {
  type      = string
  sensitive = true
}

variable "ssh_key_path" {
  type      = string
  sensitive = true
}

variable "pub_ssh_key" {
  type      = string
  sensitive = true
}

variable "service_account_id" {
  type      = string
  sensitive = true
}

variable "service_account_key_file_path" {
  type      = string
  sensitive = true
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "network_name" {
  type    = string
  default = "diplom-vpc"
}

variable "bastion_access" {
  type = object({
    ips             = list(string)
    ssh_custom_port = number
  })
  sensitive = true
}

locals {
  subnets = [
    { name = "public-a", zone = "ru-central1-a", v4_cidr = ["10.10.10.0/24"], route_table_id = null },
    { name = "public-b", zone = "ru-central1-b", v4_cidr = ["10.10.11.0/24"], route_table_id = null },
    { name = "public-d", zone = "ru-central1-d", v4_cidr = ["10.10.12.0/24"], route_table_id = null },
    { name = "private-a", zone = "ru-central1-a", v4_cidr = ["10.10.20.0/24"], route_table_id = module.to_nat_instance_route_table.id },
    { name = "private-b", zone = "ru-central1-b", v4_cidr = ["10.10.21.0/24"], route_table_id = module.to_nat_instance_route_table.id },
    { name = "private-d", zone = "ru-central1-d", v4_cidr = ["10.10.22.0/24"], route_table_id = module.to_nat_instance_route_table.id },
  ]

  bastion_sg = {
    name = "bastion-sg"
    egress = [
      {
        description    = "from bastion to internal subnets"
        protocol       = "ANY"
        from_port      = 0
        to_port        = 65535
        v4_cidr_blocks = flatten(local.subnets[*].v4_cidr)
      }
    ]
    ingress = [
      {
        description    = "from Internet to bastion"
        protocol       = "TCP"
        port           = var.bastion_access.ssh_custom_port
        v4_cidr_blocks = var.bastion_access.ips
      },
      {
        description    = "from internal subnets to bastion"
        protocol       = "ANY"
        from_port      = 0
        to_port        = 65535
        v4_cidr_blocks = flatten(local.subnets[*].v4_cidr)
      }
    ]
  }

  nat_instance_sg = {
    name = "nat-instance-sg"
    egress = [
      {
        description    = "from nat-instance to any"
        protocol       = "ANY"
        from_port      = 0
        to_port        = 65535
        v4_cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    ingress = [
      {
        description    = "from internal subnets to nat-instance"
        protocol       = "ANY"
        from_port      = 0
        to_port        = 65535
        v4_cidr_blocks = flatten(local.subnets[*].v4_cidr)
      }
    ]
  }

  bastion_cloud_init_files = [
    {
      content     = "Port ${var.bastion_access.ssh_custom_port}"
      path        = "/etc/ssh/sshd_config.d/custom_port.conf"
      permissions = "0644"
    }
  ]
}

variable "nat_instance" {
  type = object({
    allow_stopping_for_update = optional(bool, true)
    name                      = optional(string, "nat-instance")
    labels                    = optional(map(string))
    public_ip                 = optional(bool, true)
    private_ip_address        = optional(string, "10.10.10.10")
    disk_image_id             = optional(string, "fd8d631hhpuvbgn19i6o") # NAT-инстанс Ubuntu 22.04
  })
  default = {}
}

variable "bastion" {
  type = object({
    allow_stopping_for_update = optional(bool, true)
    name                      = optional(string, "bastion")
    labels                    = optional(map(string))
    public_ip                 = optional(bool, true)
    cloud_init_cmd = optional(list(string), [
      "sudo systemctl daemon-reload",
      "sudo systemctl restart ssh.socket",
      "sudo systemctl restart ssh.service"
    ])
  })
  default   = {}
  sensitive = true
}

variable "to_nat_instance_route_table" {
  type = object({
    name               = optional(string, "to-nat-instance-rt")
    destination_prefix = optional(string, "0.0.0.0/0")
  })
  default = {}
}

variable "k8s_manage_alb_backend_group" {
  type = object({
    name = optional(string, "k8s-alb-bg")
    stream_backend = list(object({
      name = optional(string, "k8s-alb-bg-stream")
      port = optional(number, 6443)
    }))
  })
  default = {
    stream_backend = [{}]
  }
}

variable "k8s_manage_alb" {
  type = object({
    name                = optional(string, "k8s-manage-alb")
    listener_name       = optional(string, "k8s-manage-alb-listener")
    listener_port       = optional(number, 6443)
    internal_ip_address = optional(string, "10.10.20.10")
  })
  default = {}
}

variable "k8s_service_lb" {
  type = object({
    name                 = optional(string, "k8s-service-lb")
    healthcheck_name     = optional(string, "k8s-service-lb-healthcheck")
    healthcheck_port     = optional(number, 10250)
    listener_name        = optional(string, "k8s-service-lb-listener")
    listener_port        = optional(number, 80)
    listener_target_port = optional(number, 31280)
    # internal_ip_address = optional(string, "10.10.20.10")
    # type = optional(string, "internal")
  })
  default = {}
}

variable "k8s" {
  type = object({
    pod_network_cidr = optional(string, "192.168.0.0/16")
    master = object({
      name   = optional(string, "k8s-master")
      labels = optional(map(string), { k8s_node_role = "k8s_master" })
      # public_ip = optional(bool, true)
      scale_policy = optional(object({
        fixed_scale_size = optional(number, 1)
        # auto_scale = optional(object({
        #   type = optional(string, "REGIONAL")
        #   cpu_utilization_target = optional(number, 80)
        #   initial_size = optional(number, 1)
        #   max_size = optional(number, 2)
        #   measurement_duration = optional(number, 60)
        #   stabilization_duration = optional(number, 600)
        #   warmup_duration = optional(number, 120)
        # }))
      }))
      deploy_policy = optional(object({
        max_expansion   = optional(number, 0)
        max_unavailable = optional(number, 1)
        # startup_duration = optional(number, 300)
        # strategy = optional(string, "opportunistic")
      }))
      instance_template = optional(object({
        resources = optional(object({
          cores         = optional(number, 4)
          memory        = optional(number, 4)
          core_fraction = optional(number, 100)
        }))
      }))
      health_check = optional(object({
        healthy_threshold = optional(number, 2)
        interval          = optional(number, 2)
        timeout           = optional(number, 1)
        port              = optional(number, 22)
      }))
      application_load_balancer = optional(object({
        ignore_health_checks = optional(bool, true)
      }))
    })
    worker = object({
      name   = optional(string, "k8s-worker")
      labels = optional(map(string), { k8s_node_role = "k8s_worker" })
      # public_ip = optional(bool, true)
      scale_policy = optional(object({
        fixed_scale_size = optional(number, 1)
        # auto_scale = optional(object({
        #   type = optional(string, "REGIONAL")
        #   cpu_utilization_target = optional(number, 80)
        #   initial_size = optional(number, 2)
        #   max_size = optional(number, 3)
        #   measurement_duration = optional(number, 60)
        #   stabilization_duration = optional(number, 600)
        #   warmup_duration = optional(number, 120)
        # }))
      }))
      deploy_policy = optional(object({
        max_expansion   = optional(number, 0)
        max_unavailable = optional(number, 1)
        # startup_duration = optional(number, 300)
        # strategy = optional(string, "opportunistic")
      }))
      instance_template = optional(object({
        resources = optional(object({
          cores         = optional(number, 6)
          memory        = optional(number, 6)
          core_fraction = optional(number, 100)
        }))
      }))
      health_check = optional(object({
        healthy_threshold = optional(number, 2)
        interval          = optional(number, 2)
        timeout           = optional(number, 1)
        port              = optional(number, 22)
      }))
      load_balancer = optional(object({
        ignore_health_checks = optional(bool, true)
      }))
    })
  })
  default = {
    master = {
      deploy_policy = {}
      instance_template = {
        resources = {}
      }
      health_check = {}
      scale_policy = {
        # auto_scale = {}   # can only be used with instances with 100% vCPU guarantee
      }
      application_load_balancer = {}
    }
    worker = {
      deploy_policy = {}
      instance_template = {
        resources = {}
      }
      health_check = {}
      scale_policy = {
        # auto_scale = {}   # can only be used with instances with 100% vCPU guarantee
      }
      load_balancer = {}
    }
  }
}

locals {
  k8s_deploy_policy_strategy = {
    # master = var.k8s.master.scale_policy.fixed_scale_size > 1 ? "proactive" : "opportunistic"
    # worker = var.k8s.worker.scale_policy.fixed_scale_size > 1 ? "proactive" : "opportunistic"
    master = "proactive"
    worker = "proactive"
  }

  k8s_first_master_ip = one([
    for vm_data in module.k8s_master.instance_inventory_data : vm_data.ip if vm_data.name == module.k8s_master.instances[0].name
  ])

  k8s_masters_inventory_data = [for master in data.yandex_compute_instance_group.k8s_master.instances : {
    name   = master.name
    labels = data.yandex_compute_instance_group.k8s_master.labels
    ip = master.network_interface[0].nat_ip_address != "" ? (
      master.network_interface[0].nat_ip_address
      ) : (
      master.network_interface[0].ip_address
    )
  }]

  k8s_workers_inventory_data = [for worker in data.yandex_compute_instance_group.k8s_worker.instances : {
    name   = worker.name
    labels = data.yandex_compute_instance_group.k8s_worker.labels
    ip = worker.network_interface[0].nat_ip_address != "" ? (
      worker.network_interface[0].nat_ip_address
      ) : (
      worker.network_interface[0].ip_address
    )
  }]

  bastion_ip_address = module.bastion.network_interface_ip_address
}

variable "ansible_inventory" {
  type = object({
    dir_path        = string
    name            = string
    connection_type = string
    content_type    = string
  })
}

variable "container_registry" {
  type = object({
    dir_path     = string
    name         = string
    content_type = string
  })
}

variable "bucket" {
  type = object({
    name       = string
    versioning = bool
  })
}

# variable "ansible_playbook" {
#   type = object({
#     requirements_file_path = optional(string, "../ansible/requirements.yml")
#     playbook_file_path = optional(string, "../ansible/main.yml")
#   })
#   default = {}
# }
