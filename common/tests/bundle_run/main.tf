locals {
  bundle_open_command = var.open_test_job ? "databricks bundle open ${var.bundle_job_name}" : "echo \"Not opening job in browser\""
  bundle_run_command  = "databricks bundle run ${var.bundle_job_name}"
}

resource "terraform_data" "run_job" {
  input = {
    working_dir         = var.working_dir
    environment         = var.environment
    bundle_open_command = local.bundle_open_command
    bundle_run_command  = local.bundle_run_command
  }

  provisioner "local-exec" {
    command     = self.input.bundle_open_command
    working_dir = self.input.working_dir
    environment = self.input.environment
  }

  provisioner "local-exec" {
    command     = self.input.bundle_run_command
    working_dir = self.input.working_dir
    environment = self.input.environment
  }
}
