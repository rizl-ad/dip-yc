variable "description" {
  type    = string
  default = null
}

variable "folder_id" {
  type    = string
  default = null
}

variable "labels" {
  type    = map(string)
  default = null
}

variable "name" {
  type = string
}

variable "network_id" {
  type = string
}

variable "static_route" {
  type = list(object({
    destination_prefix = optional(string)
    gateway_id         = optional(string)
    next_hop_address   = optional(string)
  }))
}