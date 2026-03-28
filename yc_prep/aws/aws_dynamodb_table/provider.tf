terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws",
      version = "~> 5.0"
    }
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">=0.158.0"
    }
  }
  required_version = ">=1.13.0"
}
