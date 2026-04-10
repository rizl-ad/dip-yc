module "container_registry" {
  source = "./registry"
  name   = var.app_data.name
}
