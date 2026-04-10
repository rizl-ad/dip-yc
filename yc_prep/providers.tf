terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 5.0"
    }
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">=0.158.0"
    }
  }
  required_version = ">=1.13.0"

  backend "s3" {
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = var.adm_sa_key
  zone                     = var.default_zone
}

provider "aws" {
  region = var.region
  endpoints {
    dynamodb = module.ydb_serverless.document_api_endpoint
  }
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
}
