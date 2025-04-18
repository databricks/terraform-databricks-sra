resource "databricks_job" "initializer" {
  name = "SAT Initializer Notebook (one-time)"
  dynamic "job_cluster" {
    for_each = var.run_on_serverless ? [] : [1]
    content {
      job_cluster_key = "job_cluster"
      new_cluster {
        data_security_mode = "SINGLE_USER"
        num_workers        = 5
        spark_version      = data.databricks_spark_version.latest_lts.id
        node_type_id       = data.databricks_node_type.smallest.id
        runtime_engine     = "PHOTON"
        dynamic "gcp_attributes" {
          for_each = var.gcp_impersonate_service_account == "" ? [] : [var.gcp_impersonate_service_account]
          content {
            google_service_account = var.gcp_impersonate_service_account
          }
        }
      }
    }
  }

  task {
    task_key        = "Initializer"
    job_cluster_key = var.run_on_serverless ? null : "job_cluster"
    dynamic "library" {
      for_each = var.run_on_serverless ? [] : [1]
      content {
        pypi {
          package = "dbl-sat-sdk"
        }
      }
    }
    notebook_task {
      notebook_path = "${databricks_repo.security_analysis_tool.workspace_path}/notebooks/security_analysis_initializer"
    }
  }

}

resource "databricks_job" "driver" {
  name = "SAT Driver Notebook"
  dynamic "job_cluster" {
    for_each = var.run_on_serverless ? [] : [1]
    content {
      job_cluster_key = "job_cluster"
      new_cluster {
        data_security_mode = "SINGLE_USER"
        num_workers        = 5
        spark_version      = data.databricks_spark_version.latest_lts.id
        node_type_id       = data.databricks_node_type.smallest.id
        runtime_engine     = "PHOTON"
        dynamic "gcp_attributes" {
          for_each = var.gcp_impersonate_service_account == "" ? [] : [var.gcp_impersonate_service_account]
          content {
            google_service_account = var.gcp_impersonate_service_account
          }
        }
      }
    }
  }


  task {
    task_key        = "Driver"
    job_cluster_key = var.run_on_serverless ? null : "job_cluster"
    dynamic "library" {
      for_each = var.run_on_serverless ? [] : [1]
      content {
        pypi {
          package = "dbl-sat-sdk"
        }
      }
    }
    notebook_task {
      notebook_path = "${databricks_repo.security_analysis_tool.workspace_path}/notebooks/security_analysis_driver"
    }
  }

  schedule {
    #E.G. At 08:00:00am, on every Monday, Wednesday and Friday, every month; For more: http://www.quartz-scheduler.org/documentation/quartz-2.3.0/tutorials/crontrigger.html
    quartz_cron_expression = "0 0 8 ? * Mon,Wed,Fri"
    # The system default is UTC; For more: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
    timezone_id = "America/New_York"
  }
}