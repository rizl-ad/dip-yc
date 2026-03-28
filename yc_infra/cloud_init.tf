module "cloud_init_default" {
  source = "./cloud_init"
  user_name = var.vm_user_name
  pub_ssh_key = var.pub_ssh_key
}

module "cloud_init_bastion" {
  source = "./cloud_init"
  user_name = var.vm_user_name
  pub_ssh_key = var.pub_ssh_key
  run_cmd = var.bastion.cloud_init_cmd
  cloud_init_files = local.bastion_cloud_init_files
}
