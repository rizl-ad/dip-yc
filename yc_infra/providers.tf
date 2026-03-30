terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">=0.158.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.7.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
  required_version = ">=1.13.0"
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = file(var.service_account_key_file_path)
  zone                     = var.default_zone
}