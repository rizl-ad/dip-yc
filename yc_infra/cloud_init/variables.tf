variable "user_name" {
  type = string
  sensitive = true
}

variable "pub_ssh_key" {
  type = string
  sensitive = true
}

variable "cloud_init_files" {
  type = list(object({
    content = string
    path = string
    permissions = string
  }))
  default = null
}

variable "run_cmd" {
  type = list(string)
  default = []
}
