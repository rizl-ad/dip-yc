variable "deletion_protection" {
  type = bool
  default = false
}

variable "description" {
  type = string
  default = null
}

variable "folder_id" {
  type = string
  default = null
}

variable "labels" {
  type = map(string)
  default = null
}

variable "location_id" {
  type = string
  default = null
}

variable "name" {
  type = string
}

variable "sleep_after" {
  type = number
  default = null
}

variable "serverless_database" {
  type = object({
    enable_throttling_rcu_limit = optional(bool)
    provisioned_rcu_limit = optional(number)
    storage_size_limit = optional(number)
    throttling_rcu_limit = optional(number)
  })
  default = null
}