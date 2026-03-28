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
  default = null
}

variable "network_id" {
  type = string
}

variable "egress" {
  type = list(object(
    {
      description = optional(string)
      from_port = optional(number)
      labels = optional(map(string))
      port = optional(number)
      predefined_target = optional(string)
      protocol = string
      security_group_id = optional(string)
      to_port = optional(number)
      v4_cidr_blocks = optional(list(string))
      # v6_cidr_blocks = optional(list(string))   # argument not supported yet
  }))
  default = null
  validation {
    condition = var.egress != null ? alltrue(
      [ for rule in var.egress : contains(["ANY", "TCP", "UDP", "ICMP", "IPV6_ICMP"], rule.protocol) ]
     ) : true
    error_message = "Invali egress protocol, valid values: ANY, TCP, UDP, ICMP, IPV6_ICMP"
  }
  validation {
    condition = var.egress != null ? alltrue(
      [ for rule in var.egress : rule.predefined_target != null ? (
        contains(["self_security_group", "loadbalancer_healthchecks"], rule.predefined_target) 
      ) : true ]
    ): true
    error_message = "Invali egress predefined target, valid values: \"self_security_group\", \"loadbalancer_healthchecks\""
  }
  validation {
    condition = var.egress != null ? can([
      for rule in var.egress : alltrue([
        for cidr in rule.v4_cidr_blocks : can(cidrhost(cidr, 0))
      ])
    ]) : true
    error_message = "Security group egress IPv4 CIDR must be a valid"
  }
  description = "https://yandex.cloud/ru/docs/vpc/concepts/security-groups"
}

variable "ingress" {
  type = list(object(
    {
      description = optional(string)
      from_port = optional(number)
      labels = optional(map(string))
      port = optional(number)
      predefined_target = optional(string)
      protocol = string
      security_group_id = optional(string)
      to_port = optional(number)
      v4_cidr_blocks = optional(list(string))
      # v6_cidr_blocks = optional(list(string))   # argument not supported yet
  }))
  default = null
  validation {
    condition = var.ingress != null ? alltrue(
      [ for rule in var.ingress : contains(["ANY", "TCP", "UDP", "ICMP", "IPV6_ICMP"], rule.protocol) ]
     ) : true
    error_message = "Invali ingress protocol, valid values: ANY, TCP, UDP, ICMP, IPV6_ICMP"
  }
  validation {
    condition = var.ingress != null ? alltrue(
      [ for rule in var.ingress : rule.predefined_target != null ? (
        contains(["self_security_group", "loadbalancer_healthchecks"], rule.predefined_target) 
      ) : true ]
    ): true
    error_message = "Invali ingress predefined target, valid values: \"self_security_group\", \"loadbalancer_healthchecks\""
  }
  validation {
    condition = var.ingress != null ? can([
      for rule in var.ingress : alltrue([
        for cidr in rule.v4_cidr_blocks : can(cidrhost(cidr, 0)) 
      ])
    ]) : true
    error_message = "Security group ingress IPv4 CIDR must be a valid"
  }
  description = "https://yandex.cloud/ru/docs/vpc/concepts/security-groups"
}
