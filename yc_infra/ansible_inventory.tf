data "yandex_compute_instance_group" "k8s_master" {
  depends_on        = [module.k8s_master]
  instance_group_id = module.k8s_master.id
}

data "yandex_compute_instance_group" "k8s_worker" {
  depends_on        = [module.k8s_worker]
  instance_group_id = module.k8s_worker.id
}

module "ansible_inventory_file" {
  source      = "./s3/object"
  bucket_name = var.bucket.name
  content = templatefile(
    "${path.root}/tftpl/inventory.tftpl", {
      global_vars = {
        user_name                   = var.vm_user_name
        ssh_key_path                = var.ssh_key_path
        connection_type             = var.ansible_inventory.connection_type
        apiserver_advertise_address = local.k8s_first_master_ip
        pod_network_cidr            = var.k8s.pod_network_cidr
        apiserver_cert_extra_sans = one([
          for listener in module.k8s_manage_alb.listeners :
          listener.endpoint[0].address[0].internal_ipv4_address[0].address if listener.name == var.k8s_manage_alb.listener_name
        ])
        control_plane_endpoint = one([
          for listener in module.k8s_manage_alb.listeners :
          listener.endpoint[0].address[0].internal_ipv4_address[0].address if listener.name == var.k8s_manage_alb.listener_name
        ])
        http_node_port = var.k8s_service_lb.listener_target_port
      }

      vms_data = {
        for label in distinct(flatten([
          for vm in flatten([
            local.k8s_masters_inventory_data,
            local.k8s_workers_inventory_data
          ]) : values(vm.labels)
          ])) : label => {
          hosts = [
            for vm in flatten([
              local.k8s_masters_inventory_data,
              local.k8s_workers_inventory_data
              ]) : {
              name = vm.name
              ip   = vm.ip
            } if contains(values(vm.labels), label)
          ]
          vars = {
            ansible_ssh_common_args = "-o ProxyJump=${var.vm_user_name}@${local.bastion_ip_address[0]}:${var.bastion.ssh_custom_port}"
          }
        }
      }

    }
  )
  content_type = var.ansible_inventory.content_type
  object_key   = "${var.ansible_inventory.dir_path}/${var.ansible_inventory.name}"
}
