resource "databricks_job" "initializer" {
  name = "SAT Initializer Notebook (one-time)"
  environment {
    spec {
      dependencies = ["dbl-sat-sdk"]
      client       = "1"
    }
    environment_key = "Default"
  }
  task {
    task_key        = "Initializer"
    notebook_task {
      notebook_path = "${databricks_repo.security_analysis_tool.workspace_path}/notebooks/security_analysis_initializer"
    }
  }
}

resource "databricks_job" "driver" {
  name = "SAT Driver Notebook"
  environment {
    spec {
      dependencies = ["dbl-sat-sdk"]
      client       = "1"
    }
    environment_key = "Default"
  }
  task {
    task_key        = "Driver"
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
