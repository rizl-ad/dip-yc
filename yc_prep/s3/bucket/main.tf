resource "yandex_storage_bucket" "bucket" {
  bucket = var.bucket_name
  max_size = var.max_size
  default_storage_class = var.storage_class
  tags = var.tags
  website_domain = var.website_domain
  website_endpoint = var.website_endpoint

  anonymous_access_flags {
    read = var.access_read_bucket_objects
    list = var.access_list_bucket_objects
    config_read = var.acess_read_config_bucket
  }

  dynamic "logging" {
    for_each = var.logging != null ? [var.logging] : []
    content {
      target_bucket = logging.value.target_bucket
      target_prefix = logging.value.target_prefix
    }
  }

  dynamic "server_side_encryption_configuration" {
    for_each = var.kms_master_key_id != null ? [1] : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = var.kms_master_key_id
          sse_algorithm = var.kms_master_key_id != null ? "aws:kms" : null
        }
      }
    }
  }

  versioning {
    enabled = var.versioning
  }

  dynamic "website" {
    for_each = var.website != null ? [var.website] : []
    content {
      error_document = website.value.error_document
      index_document = website.value.index_document
      redirect_all_requests_to = website.value.redirect_all_requests_to
      routing_rules = website.value.redirect_all_requests_to
    }
  }

}

output "bucket" {
  value = yandex_storage_bucket.bucket.bucket
}

output "bucket_id" {
  value = yandex_storage_bucket.bucket.id
}

output "bucket_domain_name" {
  value = yandex_storage_bucket.bucket.bucket_domain_name
}
