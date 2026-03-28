resource "yandex_vpc_security_group" "security_group" {
  description = var.description
  folder_id = var.folder_id
  labels = var.labels
  name = var.name
  network_id = var.network_id

  dynamic "egress" {
    for_each = var.egress != null ? var.egress : []
    content {
      description = lookup(egress.value, "description", null)
      from_port = lookup(egress.value, "from_port", null)
      labels = lookup(egress.value, "labels", null)
      port = lookup(egress.value, "port", null)
      predefined_target = lookup(egress.value, "predefined_target", null)
      protocol = lookup(egress.value, "protocol", null)
      security_group_id = lookup(egress.value, "security_group_id", null)
      to_port = lookup(egress.value, "to_port", null)
      v4_cidr_blocks = lookup(egress.value, "v4_cidr_blocks", null)
      # v6_cidr_blocks = lookup(egress.value, "v6_cidr_blocks", null)   # argument not supported yet
    }
  }

  dynamic "ingress" {
    for_each = var.ingress != null ? var.ingress : []
    content {
      description = lookup(ingress.value, "description", null)
      from_port = lookup(ingress.value, "from_port", null)
      labels = lookup(ingress.value, "labels", null)
      port = lookup(ingress.value, "port", null)
      predefined_target = lookup(ingress.value, "predefined_target", null)
      protocol = lookup(ingress.value, "protocol", null)
      security_group_id = lookup(ingress.value, "security_group_id", null)
      to_port = lookup(ingress.value, "to_port", null)
      v4_cidr_blocks = lookup(ingress.value, "v4_cidr_blocks", null)
      # v6_cidr_blocks = lookup(ingress.value, "v6_cidr_blocks", null)   # argument not supported yet
    }
  }

}

output "created_at" {
  value = yandex_vpc_security_group.security_group.created_at
}

output "id" {
  value = yandex_vpc_security_group.security_group.id
}

output "status" {
  value = yandex_vpc_security_group.security_group.status
}

output "egress_ids" {
  value = yandex_vpc_security_group.security_group.egress[*].id
}

output "ingress_ids" {
  value = yandex_vpc_security_group.security_group.ingress[*].id
}

