resource "yandex_kms_symmetric_key" "symmetric_key" {
  default_algorithm = var.default_algorithm
  deletion_protection = var.deletion_protection
  description = var.description
  folder_id = var.folder_id
  labels = var.labels
  name = var.name
  rotation_period = var.rotation_period
  symmetric_key_id = var.symmetric_key_id
}

output "created_at" {
  value = yandex_kms_symmetric_key.symmetric_key.created_at
}

output "rotated_at" {
  value = yandex_kms_symmetric_key.symmetric_key.rotated_at
}

output "status" {
  value = yandex_kms_symmetric_key.symmetric_key.status
}

output "id" {
  value = yandex_kms_symmetric_key.symmetric_key.id
}
