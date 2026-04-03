variable "cloud_id" {
  type = string
}

variable "region" {
  type    = string
  default = "ru-central1"
}

variable "default_zone" {
  type    = string
  default = "ru-central1-a"
}

variable "folder_id" {
  type = string
}

variable "adm_sa_key" {
  type      = string
  sensitive = true
}

variable "sa" {
  type = object({
    name = optional(string, "diplom-sa")
    roles = optional(list(string), [
      "editor", "k8s.clusters.agent", "load-balancer.admin", "vpc.publicAdmin",
      "k8s.tunnelClusters.agent", "container-registry.images.pusher", "container-registry.images.puller"
    ])
    key_algorithm = optional(string, "RSA_2048")
  })
  default = {
    key = {}
  }
  sensitive = true
}

variable "sa_key_file" {
  type = object({
    dir_path     = string
    content_type = string
    name         = string
  })
  sensitive = true
}

variable "aws_access_profile" {
  type    = string
  default = "diplom"
}

variable "aws_access_file" {
  type = object({
    dir_path     = string
    content_type = string
    name         = string
  })
  sensitive = true
}

variable "symmetric_key" {
  type = object({
    name                = optional(string, "diplom-simmetric-key")
    algorithm           = optional(string, "AES_256")
    deletion_protection = optional(bool, true)
    rotation_period     = optional(string, "2160h")
  })
  default = {}
}

variable "bucket" {
  type = object({
    name       = string
    versioning = bool
  })
}

variable "ydb" {
  type = object({
    deletion_protection         = optional(bool, true)
    name                        = optional(string, "diplom-ydb")
    enable_throttling_rcu_limit = optional(bool, true)
    throttling_rcu_limit        = optional(number, 10)
    size                        = optional(number, 1)
  })
  default = {}
}

variable "dynamodb_table" {
  type = object({
    name = optional(string, "infra/tf-state-lock")
    attribute = list(object({
      name = optional(string, "LockID")
      type = optional(string, "S")
    }))
  })
  default = {
    attribute = [{}]
  }
}

variable "backend_file" {
  type = object({
    dir_path     = string
    content_type = string
    name         = string
  })
}

variable "vars_file" {
  type = object({
    dir_path     = string
    content_type = string
    name         = string
  })
}


