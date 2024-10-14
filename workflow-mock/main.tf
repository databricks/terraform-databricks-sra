resource "null_resource" "some_resource" {
  triggers = {
    example = var.TRIGGER_VALUE
  }
}
