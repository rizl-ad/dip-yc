module "k8s_master" {
  source             = "./vm/vm_group"
  service_account_id = var.service_account_id
  labels             = var.k8s.master.labels
  name               = var.k8s.master.name
  allocation_policy = {
    zones = [for subnet in module.vpc_subnet.subnets : subnet.zone if can(regex("^private", subnet.name))]
  }
  deploy_policy = {
    max_expansion   = var.k8s.master.deploy_policy.max_expansion
    max_unavailable = var.k8s.master.deploy_policy.max_unavailable
    # startup_duration = var.k8s.master.deploy_policy.startup_duration
    strategy = local.k8s_deploy_policy_strategy.master
  }
  instance_template = {
    boot_disk = {
      initialize_params = {}
    }
    resources = {
      core_fraction = var.k8s.master.instance_template.resources.core_fraction
      cores         = var.k8s.master.instance_template.resources.cores
      memory        = var.k8s.master.instance_template.resources.memory
    }
    network_interface = [{
      subnet_ids = [for subnet in module.vpc_subnet.subnets : subnet.id if can(regex("^private", subnet.name))]
    }]
    name     = var.k8s.master.name
    hostname = var.k8s.master.name
    labels   = var.k8s.master.labels
    metadata = {
      user-data = module.cloud_init_default.content
    }
  }
  scale_policy = {
    fixed_scale = {
      size = var.k8s.master.scale_policy.fixed_scale_size
    }
    # auto_scale = {    # can only be used with instances with 100% vCPU guarantee
    #   auto_scale_type = var.k8s.master.scale_policy.auto_scale.type
    #   cpu_utilization_target = var.k8s.master.scale_policy.auto_scale.cpu_utilization_target
    #   initial_size = var.k8s.master.scale_policy.auto_scale.initial_size
    #   max_size = var.k8s.master.scale_policy.auto_scale.max_size
    #   measurement_duration = var.k8s.master.scale_policy.auto_scale.measurement_duration
    #   stabilization_duration = var.k8s.master.scale_policy.auto_scale.stabilization_duration
    #   warmup_duration = var.k8s.master.scale_policy.auto_scale.warmup_duration
    # }
  }
  health_check = {
    healthy_threshold = var.k8s.master.health_check.healthy_threshold
    interval          = var.k8s.master.health_check.interval
    timeout           = var.k8s.master.health_check.timeout
    tcp_options = {
      port = var.k8s.master.health_check.port
    }
  }
  application_load_balancer = {
    ignore_health_checks = var.k8s.master.application_load_balancer.ignore_health_checks
  }
}

module "k8s_worker" {
  source             = "./vm/vm_group"
  service_account_id = var.service_account_id
  labels             = var.k8s.worker.labels
  name               = var.k8s.worker.name
  allocation_policy = {
    zones = [for subnet in module.vpc_subnet.subnets : subnet.zone if can(regex("^private", subnet.name))]
  }
  deploy_policy = {
    max_expansion   = var.k8s.worker.deploy_policy.max_expansion
    max_unavailable = var.k8s.worker.deploy_policy.max_unavailable
    # startup_duration = var.k8s.worker.deploy_policy.startup_duration
    strategy = local.k8s_deploy_policy_strategy.worker
  }
  instance_template = {
    boot_disk = {
      initialize_params = {
        size = var.k8s.worker.instance_template.boot_disk.size
      }
    }
    resources = {
      core_fraction = var.k8s.worker.instance_template.resources.core_fraction
      cores         = var.k8s.worker.instance_template.resources.cores
      memory        = var.k8s.worker.instance_template.resources.memory
    }
    network_interface = [{
      subnet_ids = [for subnet in module.vpc_subnet.subnets : subnet.id if can(regex("^private", subnet.name))]
    }]
    name     = var.k8s.worker.name
    hostname = var.k8s.worker.name
    labels   = var.k8s.worker.labels
    metadata = {
      user-data = module.cloud_init_default.content
    }
  }
  scale_policy = {
    fixed_scale = {
      size = var.k8s.worker.scale_policy.fixed_scale_size
    }
    # auto_scale = {    # can only be used with instances with 100% vCPU guarantee
    #   auto_scale_type = var.k8s.worker.scale_policy.auto_scale.type
    #   cpu_utilization_target = var.k8s.worker.scale_policy.auto_scale.cpu_utilization_target
    #   initial_size = var.k8s.worker.scale_policy.auto_scale.initial_size
    #   max_size = var.k8s.worker.scale_policy.auto_scale.max_size
    #   measurement_duration = var.k8s.worker.scale_policy.auto_scale.measurement_duration
    #   stabilization_duration = var.k8s.worker.scale_policy.auto_scale.stabilization_duration
    #   warmup_duration = var.k8s.worker.scale_policy.auto_scale.warmup_duration
    # }
  }
  health_check = {
    healthy_threshold = var.k8s.worker.health_check.healthy_threshold
    interval          = var.k8s.worker.health_check.interval
    timeout           = var.k8s.worker.health_check.timeout
    tcp_options = {
      port = var.k8s.worker.health_check.port
    }
  }
  load_balancer = {
    ignore_health_checks = var.k8s.worker.load_balancer.ignore_health_checks
  }
}