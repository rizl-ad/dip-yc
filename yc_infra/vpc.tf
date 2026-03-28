module "vpc_net" {
  source = "./vpc/vpc_net"
  net_name = var.network_name
}

module "vpc_subnet" {
  source = "./vpc/vpc_subnet"
  network_id = module.vpc_net.id
  subnets = local.subnets
}
