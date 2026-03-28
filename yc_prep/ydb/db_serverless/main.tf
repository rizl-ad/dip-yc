resource "yandex_ydb_database_serverless" "ydb_db_serverless" {
  deletion_protection = var.deletion_protection
  description = var.description
  folder_id = var.folder_id
  labels = var.labels
  location_id = var.location_id
  name = var.name
  sleep_after = var.sleep_after

  dynamic "serverless_database" {
    for_each = var.serverless_database != null ? [1] : []
    content {
      enable_throttling_rcu_limit = var.serverless_database.enable_throttling_rcu_limit
      provisioned_rcu_limit = var.serverless_database.provisioned_rcu_limit
      storage_size_limit = var.serverless_database.storage_size_limit
      throttling_rcu_limit = var.serverless_database.throttling_rcu_limit
    }
  }
}

output "created_at" {
  value = yandex_ydb_database_serverless.ydb_db_serverless.created_at
}

output "database_path" {
  value = yandex_ydb_database_serverless.ydb_db_serverless.database_path
}

output "document_api_endpoint" {
  value = yandex_ydb_database_serverless.ydb_db_serverless.document_api_endpoint
}

output "status" {
  value = yandex_ydb_database_serverless.ydb_db_serverless.status
}

output "tls_enabled" {
  value = yandex_ydb_database_serverless.ydb_db_serverless.tls_enabled
}

output "ydb_api_endpoint" {
  value = yandex_ydb_database_serverless.ydb_db_serverless.ydb_api_endpoint
}

output "ydb_full_endpoint" {
  value = yandex_ydb_database_serverless.ydb_db_serverless.ydb_full_endpoint
}
