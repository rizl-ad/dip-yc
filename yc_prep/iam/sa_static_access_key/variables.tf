variable "description" {
  type = string
  default = null
}

variable "pgp_key" {
  type = string
  default = null
}

variable "service_account_id" {
  type = string
}

variable "output_to_lockbox" {
  type = object({
    entry_for_access_key = string
    entry_for_secret_key = string
    secret_id = string
  })
  default = null
}