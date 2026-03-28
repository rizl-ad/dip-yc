resource "yandex_iam_service_account_key" "sa_key" {
  description = var.description
  format = var.format
  key_algorithm = var.key_algorithm
  pgp_key = var.pgp_key
  service_account_id = var.service_account_id
  
  dynamic "output_to_lockbox" {
    for_each = var.output_to_lockbox != null ? [1] : []
    content {
      entry_for_private_key = var.output_to_lockbox.entry_for_private_key
      secret_id = var.output_to_lockbox.secret_id
    }
  }
}

output "created_at" {
  value = yandex_iam_service_account_key.sa_key.created_at
}

output "encrypted_private_key" {
  value = yandex_iam_service_account_key.sa_key.encrypted_private_key
}

output "id" {
  value = yandex_iam_service_account_key.sa_key.id
}

output "key_fingerprint" {
  value = yandex_iam_service_account_key.sa_key.key_fingerprint
  sensitive = true
}

output "output_to_lockbox_version_id" {
  value = yandex_iam_service_account_key.sa_key.output_to_lockbox_version_id
}

output "private_key" {
  value = yandex_iam_service_account_key.sa_key.private_key
  sensitive = true
}

output "public_key" {
  value = yandex_iam_service_account_key.sa_key.public_key
  sensitive = true
}