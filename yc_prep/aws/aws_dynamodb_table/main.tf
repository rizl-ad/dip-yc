resource "aws_dynamodb_table" "dynamodb_table" {
  name = var.name
  billing_mode = var.billing_mode
  hash_key = var.hash_key
  range_key = var.range_key

  dynamic "attribute" {
    for_each = var.attribute
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }
}