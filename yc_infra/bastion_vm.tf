module "bastion" {
  depends_on                = [module.nat_instance]
  source                    = "./vm/vm"
  allow_stopping_for_update = var.bastion.allow_stopping_for_update
  hostname                  = var.bastion.name
  labels                    = var.bastion.labels
  metadata = {
    user-data = module.cloud_init_bastion.content
  }
  name = var.bastion.name
  network_interface = [{
    nat                = var.bastion.public_ip
    security_group_ids = [module.bastion_sg.id]
    subnet_id          = [for subnet in module.vpc_subnet.subnets : subnet.id if can(regex("^public", subnet.name))][0]
  }]
  zone = [for subnet in module.vpc_subnet.subnets : subnet.zone if can(regex("^public", subnet.name))][0]
}