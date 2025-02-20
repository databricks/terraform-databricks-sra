config {
  variables = ["tags={\"foo\"=\"bar\"}"]
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
  enabled = false
  tags = ["foo"]
}
