module "to_nat_instance_route_table" {
  source     = "./vpc/route_table"
  name       = var.to_nat_instance_route_table.name
  network_id = module.vpc_net.id
  static_route = [
    {
      destination_prefix = var.to_nat_instance_route_table.destination_prefix
      next_hop_address   = var.nat_instance.private_ip_address
    }
  ]
}