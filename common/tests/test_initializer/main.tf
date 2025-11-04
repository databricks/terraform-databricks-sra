# This is used to fetch the current state workspace. The terraform test framework does not support using the typical
# terraform.workspace to fetch this information.
data "external" "workspace" {
  program     = ["sh", "-c", "echo '{\"name\":\"'$(terraform workspace show)'\"}'"]
  working_dir = path.cwd
}

data "terraform_remote_state" "state" {
  backend = "local"

  config = {
    path = data.external.workspace.result.name == "default" ? "${path.cwd}/terraform.tfstate" : "${path.cwd}/terraform.tfstate.d/${data.external.workspace.result.name}/terraform.tfstate"
  }
}
