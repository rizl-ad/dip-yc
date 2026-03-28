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

variable "name" {
  type = string
}

variable "service_account_id" {
  type = string
  default = null
}