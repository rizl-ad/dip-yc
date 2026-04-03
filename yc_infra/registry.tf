module "container_registry" {
  source = "./registry"
  name   = var.container_registry.name
}

module "registry_file" {
  source      = "./s3/object"
  bucket_name = var.bucket.name
  content = jsonencode({
    id = module.container_registry.id
  })
  content_type = var.container_registry.content_type
  object_key   = "${var.container_registry.dir_path}/${var.container_registry.name}"
}