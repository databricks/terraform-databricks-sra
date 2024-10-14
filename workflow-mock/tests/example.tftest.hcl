# variable_precedence.tftest.hcl

run "null_resource_trigger_default" {

  command = plan

  assert {
    condition     = null_resource.some_resource.triggers["example"] == "test"
    error_message = "Null resource trigger does not match expected value"
  }
}
