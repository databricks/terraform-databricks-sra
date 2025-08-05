data "terraform_remote_state" "state" {
  backend = "local"

  config = {
    path = "${path.cwd}/terraform.tfstate"
  }
}
