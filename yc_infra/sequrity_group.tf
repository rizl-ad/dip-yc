module "bastion_sg" {
  source = "./vpc/vpc_sg"
  name = local.bastion_sg.name
  network_id = module.vpc_net.id
  egress = local.bastion_sg.egress
  ingress = local.bastion_sg.ingress
}

module "nat_instance_sg" {
  source = "./vpc/vpc_sg"
  name = local.nat_instance_sg.name
  network_id = module.vpc_net.id
  egress = local.nat_instance_sg.egress
  ingress = local.nat_instance_sg.ingress
}
