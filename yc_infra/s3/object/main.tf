resource "yandex_storage_object" "storage_object" {
  access_key = var.access_key
  acl = var.acl
  bucket = var.bucket_name
  content = var.content
  content_base64 = var.content_base64
  content_type = var.content_type
  key = var.object_key
  object_lock_legal_hold_status = var.object_lock_legal_hold_status
  object_lock_mode = var.object_lock_mode
  object_lock_retain_until_date = var.object_lock_retain_until_date
  secret_key = var.secret_key
  source = var.source_object
  source_hash = var.source_object_hash
  tags = var.tags
}

output "id" {
  value = yandex_storage_object.storage_object.id
}

output "key" {
  value = yandex_storage_object.storage_object.key
}