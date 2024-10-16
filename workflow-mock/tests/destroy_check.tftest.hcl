run "null_resource_trigger_default_apply" {

  variables {
    trigger_value = "test2"
  }

  assert {
    condition     = null_resource.some_resource.triggers["example"] == "test2"
    error_message = "Null resource trigger does not match expected value"
  }
}

run "null_resource_trigger_non_default_plan" {

  command = plan

  assert {
    condition     = null_resource.some_resource.triggers["example"] == "test"
    error_message = "Null resource trigger does not match expected value"
  }
}
