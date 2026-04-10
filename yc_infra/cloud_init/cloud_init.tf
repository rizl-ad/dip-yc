locals {
  content = templatefile(
    "${path.module}/cloud_init.tftpl", {
      user_name   = var.user_name
      pub_ssh_key = var.pub_ssh_key
      run_cmd     = var.run_cmd
      files       = var.cloud_init_files
    }
  )
}

output "content" {
  value     = local.content
  sensitive = true
}