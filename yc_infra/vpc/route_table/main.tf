resource "yandex_vpc_route_table" "route_table" {
  description = var.description
  folder_id   = var.folder_id
  labels      = var.labels
  name        = var.name
  network_id  = var.network_id


  dynamic "static_route" {
    for_each = var.static_route != null ? var.static_route : []
    content {
      destination_prefix = static_route.value.destination_prefix
      gateway_id         = static_route.value.gateway_id
      next_hop_address   = static_route.value.next_hop_address
    }
  }
}

output "created_at" {
  value = yandex_vpc_route_table.route_table.created_at
}

output "id" {
  value = yandex_vpc_route_table.route_table.id
}