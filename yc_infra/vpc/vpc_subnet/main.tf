resource "yandex_vpc_subnet" "subnet" {
  count = length(var.subnets)
  name = var.subnets[count.index].name
  zone = var.subnets[count.index].zone
  network_id = var.network_id
  v4_cidr_blocks = var.subnets[count.index].v4_cidr
  route_table_id = var.subnets[count.index].route_table_id
}

output "subnets" {
  value = yandex_vpc_subnet.subnet[*]
}