variable "name" {
  type = string
}

variable "billing_mode" {
  type = string
  default = "PAY_PER_REQUEST"
  description = "https://yandex.cloud/ru/docs/ydb/terraform/dynamodb-tables"
}

variable "hash_key" {
  type = string
  default = null
}

variable "range_key" {
  type = string
  default = null
}

variable "attribute" {
  type = list(object({
    name = string
    type = string
  }))
  validation {
    condition = alltrue([ for attr in var.attribute : contains(["S", "N"], attr.type) ])
    error_message = "Invalid dynamoDB table attribute type, valid values: \"S\", \"N\""
  }
  description = "https://yandex.cloud/ru/docs/ydb/terraform/dynamodb-tables"
}
