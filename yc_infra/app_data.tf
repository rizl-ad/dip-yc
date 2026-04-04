module "app_data_file" {
  source      = "./s3/object"
  bucket_name = var.bucket.name
  content = jsonencode({
    registry_id = module.container_registry.id
    port        = var.k8s_service_lb.listener_port
  })
  content_type = var.app_data.content_type
  object_key   = "${var.app_data.dir_path}/${var.app_data.name}"
}