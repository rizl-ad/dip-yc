variable "network_id" {
  type = string
}

variable "subnets" {
  type = list(
    object({
      name = string,
      zone = string,
      v4_cidr = list(string),
      route_table_id = string
    })
  )
  default = [
    { name = "subnet-a", zone = "ru-central1-a", v4_cidr = ["10.0.1.0/24", "10.0.11.0/24", "10.0.21.0/24"], route_table_id = null },
    { name = "subnet-b", zone = "ru-central1-b", v4_cidr = ["10.0.2.0/24", "10.0.12.0/24", "10.0.22.0/24"], route_table_id = null },
    { name = "subnet-d", zone = "ru-central1-d", v4_cidr = ["10.0.3.0/24", "10.0.13.0/24", "10.0.23.0/24"], route_table_id = null },
  ]
}
