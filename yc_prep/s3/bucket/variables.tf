variable "bucket_name" {
  type = string
  default = null
}

variable "max_size" {
  type = number
  default = 1073741824   # 1 GB - value in bytes
}

variable "storage_class" {
  type = string
  default = "STANDARD"
  validation {
    condition = contains(["STANDARD", "COLD", "ICE"], var.storage_class)
    error_message = "Invalid storage class, valid values: \"STANDARD\", \"COLD\", \"ICE\""
  }
  description = "https://yandex.cloud/ru/docs/storage/concepts/storage-class"
}

variable "tags" {
  type = map(string)
  default = null
  description = "https://yandex.cloud/ru/docs/storage/concepts/tags"
}

variable "website_domain" {
  type = string
  default = null
  description = "https://yandex.cloud/ru/docs/tutorials/web/static/, https://yandex.cloud/ru/docs/storage/concepts/hosting"
}

variable "website_endpoint" {
  type = string
  default = null
  description = "https://yandex.cloud/ru/docs/tutorials/web/static/, https://yandex.cloud/ru/docs/storage/concepts/hosting"
}

variable "access_read_bucket_objects" {
  type = bool
  default = false
  description = "https://yandex.cloud/ru/docs/storage/operations/buckets/bucket-availability"
}

variable "access_list_bucket_objects" {
  type = bool
  default = false
  description = "https://yandex.cloud/ru/docs/storage/operations/buckets/bucket-availability"
}

variable "acess_read_config_bucket" {
  type = bool
  default = false
  description = "https://yandex.cloud/ru/docs/storage/operations/buckets/bucket-availability"
}

variable "logging" {
  type = object({
    target_bucket = string
    target_prefix = optional(string)
  })
  default = null
  description = "https://yandex.cloud/ru/docs/storage/concepts/server-logs"
}

variable "kms_master_key_id" {
  type = string
  default = null
  description = "https://yandex.cloud/ru/docs/tutorials/security/server-side-encryption"
}

variable "versioning" {
  type = bool
  default = false
  description = "https://yandex.cloud/ru/docs/storage/concepts/versioning"
}

variable "website" {
  type = object({
    error_document = optional(string)
    index_document = optional(string)
    redirect_all_requests_to = optional(string)
    routing_rules = optional(string)
  })
  default = null
  description = "https://yandex.cloud/ru/docs/tutorials/web/static/, https://yandex.cloud/ru/docs/storage/concepts/hosting"
}

