locals {
  working_dir = "${path.module}/bundle"
  environment = var.environment
}

data "databricks_node_type" "smallest" {
  local_disk            = true
  photon_driver_capable = true
  photon_worker_capable = true
  min_cores             = 3
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
  ml                = true
}

resource "terraform_data" "bundle" {
  input = {
    working_dir = local.working_dir
    environment = local.environment
  }

  provisioner "local-exec" {
    command     = "databricks bundle deploy --auto-approve"
    working_dir = self.input.working_dir
    environment = self.input.environment
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "databricks bundle destroy --auto-approve"
    working_dir = self.input.working_dir
    environment = self.input.environment
  }
}
