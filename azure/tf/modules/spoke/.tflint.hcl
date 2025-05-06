config {
  variables = ["tags={\"example\"=\"value\"}"]
}

plugin "terraform" {
  enabled = true
}

plugin "azurerm" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

rule "azurerm_resource_missing_tags" {
  enabled = true
  tags    = ["example"]
}
