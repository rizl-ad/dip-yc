resource "yandex_iam_service_account_static_access_key" "sa_static_access_key" {
  description = var.description
  pgp_key = var.pgp_key
  service_account_id = var.service_account_id

  dynamic "output_to_lockbox" {
    for_each = var.output_to_lockbox != null ? [1] : []
    content {
      entry_for_access_key = var.output_to_lockbox.entry_for_access_key
      entry_for_secret_key = var.output_to_lockbox.entry_for_secret_key
      secret_id = var.output_to_lockbox.secret_id
    }
  }
}

output "access_key" {
  value = yandex_iam_service_account_static_access_key.sa_static_access_key.access_key
  sensitive = true
}

output "created_at" {
  value = yandex_iam_service_account_static_access_key.sa_static_access_key.created_at
}

output "encrypted_secret_key" {
  value = yandex_iam_service_account_static_access_key.sa_static_access_key.encrypted_secret_key
}

output "id" {
  value = yandex_iam_service_account_static_access_key.sa_static_access_key.id
}

output "key_fingerprint" {
  value = yandex_iam_service_account_static_access_key.sa_static_access_key.key_fingerprint
  sensitive = true
}

output "output_to_lockbox_version_id" {
  value = yandex_iam_service_account_static_access_key.sa_static_access_key.output_to_lockbox_version_id
}

output "secret_key" {
  value = yandex_iam_service_account_static_access_key.sa_static_access_key.secret_key
  sensitive = true
}
