module "container_registry" {
  source = "./registry"
  name = var.container_registry_name
}