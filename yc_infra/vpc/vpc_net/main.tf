resource "yandex_vpc_network" "network" {
  name = var.net_name
}

output "id" {
  value = yandex_vpc_network.network.id
}