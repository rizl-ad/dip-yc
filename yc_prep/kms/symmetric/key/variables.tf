variable "name" {
  type = string
  default = null
}

variable "description" {
  type = string
  default = null
}

variable "folder_id" {
  type = string
  default = null
}

variable "default_algorithm" {
  type = string
  default = "AES_128"
  description = "https://yandex.cloud/ru/docs/kms/concepts/key#parameters"
  validation {
    condition = contains(["AES_128", "AES_192", "AES_256", "AES_256_HSM", "GOST_R_3412_2015_K"], var.default_algorithm)
    error_message = "Default encrypting algorithm must be one of: \"AES_128\", \"AES_192\", \"AES_256\", \"AES_256_HSM\", \"GOST_R_3412_2015_K\""
  }
}

variable "deletion_protection" {
  type = bool
  default = null
  description = "https://yandex.cloud/ru/docs/kms/concepts/key#parameters"
}

variable "labels" {
  type = map(string)
  default = null
}

variable "rotation_period" {
  type = string
  default = null
  description = "https://yandex.cloud/ru/docs/kms/concepts/key#parameters"
}

variable "symmetric_key_id" {
  type = string
  default = null
  description = "https://yandex.cloud/ru/docs/kms/concepts/key#parameters"
}
