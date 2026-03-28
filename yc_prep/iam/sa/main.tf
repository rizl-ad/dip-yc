resource "yandex_iam_service_account" "service_account" {
  description = var.description
  folder_id = var.folder_id
  labels = var.labels
  name = var.name
  service_account_id = var.service_account_id
}

output "created_at" {
  value = yandex_iam_service_account.service_account.created_at
}

output "id" {
  value = yandex_iam_service_account.service_account.id
}
