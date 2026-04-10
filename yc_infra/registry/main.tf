resource "yandex_container_registry" "container_registry" {
  folder_id   = var.folder_id
  labels      = var.labels
  name        = var.name
  registry_id = var.registry_id
}

output "created_at" {
  value = yandex_container_registry.container_registry.created_at
}

output "id" {
  value = yandex_container_registry.container_registry.id
}

output "status" {
  value = yandex_container_registry.container_registry.status
}