module "nat_instance" {
  source                    = "./vm/vm"
  allow_stopping_for_update = var.nat_instance.allow_stopping_for_update
  hostname                  = var.nat_instance.name
  labels                    = var.nat_instance.labels
  boot_disk = {
    initialize_params = {
      image_id = var.nat_instance.disk_image_id
    }
  }
  metadata = {
    user-data = module.cloud_init_default.content
  }
  name = var.nat_instance.name
  network_interface = [{
    ip_address         = var.nat_instance.private_ip_address
    nat                = var.nat_instance.public_ip
    security_group_ids = [module.nat_instance_sg.id]
    subnet_id          = [for subnet in module.vpc_subnet.subnets : subnet.id if can(regex("^public", subnet.name))][0]
  }]
  zone = [for subnet in module.vpc_subnet.subnets : subnet.zone if can(regex("^public", subnet.name))][0]
}