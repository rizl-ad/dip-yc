variable "description" {
  type    = string
  default = null
}

variable "format" {
  type    = string
  default = "PEM_FILE"
}

variable "key_algorithm" {
  type    = string
  default = "RSA_2048"
  validation {
    condition     = contains(["RSA_2048", "RSA_4096"], var.key_algorithm)
    error_message = "Invalid service account key algorithm, valid values: \"RSA_2048\", \"RSA_4096\""
  }
}

variable "pgp_key" {
  type    = string
  default = null
}

variable "service_account_id" {
  type = string
}

variable "output_to_lockbox" {
  type = object({
    entry_for_private_key = string
    secret_id             = string
  })
  default = null
}