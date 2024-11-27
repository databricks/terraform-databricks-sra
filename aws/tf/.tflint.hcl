config {
  # This can be uncommented if variables should be passed to the TF configuration during TFLint commands
  # variables = ["tags={\"foo\"=\"bar\"}"]
}

plugin "terraform" {
  enabled = true
}

plugin "aws" {
  enabled = true
  version = "0.35.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
