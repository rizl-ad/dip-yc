module "k8s_service_lb" {
  source = "./lb/net"
  name = var.k8s_service_lb.name
  # type = var.k8s_service_lb.type
  attached_target_group = {
    target_group_id = module.k8s_worker.load_balancer_target_group_id[0]
    healthcheck = {
      name = var.k8s_service_lb.healthcheck_name
      tcp_options = {
        port = var.k8s_service_lb.healthcheck_port
      }
    }
  }
  listener = {
    name = var.k8s_service_lb.listener_name
    port = var.k8s_service_lb.listener_port
    target_port = var.k8s_service_lb.listener_target_port
    external_address_spec = {}
    # internal_address_spec = {
    #   address = var.k8s_service_lb.internal_ip_address
    #   subnet_id = [ for subnet in module.vpc_subnet.subnets : subnet.id if can(regex("^private", subnet.name)) ][0]
    # }
  }
}

module "k8s_manage_alb_backend_group" {
  source = "./lb/app/alb_backend_group"
  name = var.k8s_manage_alb_backend_group.name
  stream_backend = [{
    name = var.k8s_manage_alb_backend_group.stream_backend[0].name
    port = var.k8s_manage_alb_backend_group.stream_backend[0].port
    target_group_ids = [ module.k8s_master.application_load_balancer_target_group_id[0] ]
    healthcheck = [{
      timeout = "1s"
      interval = "1s"
      healthcheck_port = var.k8s_manage_alb_backend_group.stream_backend[0].port
        stream_healthcheck = {}
    }]
    load_balancing_config = {}
  }]
}

module "k8s_manage_alb" {
  source = "./lb/app/alb"
  name = var.k8s_manage_alb.name
  network_id = module.vpc_net.id
  allocation_policy = {
    location = [
      for subnet in module.vpc_subnet.subnets : {
        subnet_id = subnet.id
        zone_id = subnet.zone
      } if can(regex("^private", subnet.name))
    ]
  }
  listener = [{
    name = var.k8s_manage_alb.listener_name
    endpoint = {
      ports = [ var.k8s_manage_alb.listener_port]
      address = {
        internal_ipv4_address = {
          address = var.k8s_manage_alb.internal_ip_address
          subnet_id = [ for subnet in module.vpc_subnet.subnets : subnet.id if can(regex("^private", subnet.name)) ][0]
        }
      }
    }
    stream = {
      handler = {
        backend_group_id = module.k8s_manage_alb_backend_group.id
      }
    }
  }]
}
