locals {
  job_name = "sra_test_spark_classic"
}

# Look up the current user
data "databricks_current_user" "me" {}

# Upload notebook to run in job
resource "databricks_notebook" "this" {
  path     = "${data.databricks_current_user.me.home}/job_notebook"
  source   = "${path.module}/notebooks/notebook.ipynb"
}

# Create a job to use for testing spark
resource "databricks_job" "classic_job" {
  name = local.job_name

  # Job tasks
  task {
    task_key        = "notebook_task"
    notebook_task {
      notebook_path   = databricks_notebook.this.path
    }
    existing_cluster_id = var.cluster_id
  }
}

resource "terraform_data" "job_run" {
  triggers_replace = [databricks_job.classic_job.id]
  provisioner "local-exec" {
    command = "databricks jobs run-now ${databricks_job.classic_job.id}"
    environment = {
      DATABRICKS_HOST = var.databricks_host
    }
  }
}
