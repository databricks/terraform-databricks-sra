resource "null_resource" "some_resource" {
  triggers = {
    example = var.trigger_value
  }
}
