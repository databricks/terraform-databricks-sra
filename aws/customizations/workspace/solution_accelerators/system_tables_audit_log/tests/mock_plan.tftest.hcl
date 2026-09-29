mock_provider "databricks" {}

variables {
  alert_emails = ["security-team@example.com"]
}

# Plans the audit-log detections: every query in queries_and_alerts.json becomes a query, every entry with an alert
# becomes an alert, and each alert is scheduled as a job task that notifies the alert emails. Without a warehouse_id,
# a dedicated SQL warehouse is created.
run "plan_valid_configuration" {
  command = plan

  assert {
    condition     = length(databricks_query.query) == length(jsondecode(file("queries_and_alerts.json"))["queries_and_alerts"])
    error_message = "Every entry in queries_and_alerts.json must become a query."
  }

  assert {
    condition     = toset([for t in databricks_job.this.task : t.task_key]) == toset(keys(databricks_alert.alert))
    error_message = "Every alert must be scheduled as a job task."
  }

  assert {
    condition     = alltrue([for t in databricks_job.this.task : [for s in t.sql_task[0].alert[0].subscriptions : s.user_name] == ["security-team@example.com"]])
    error_message = "Every alert task must notify the configured alert emails."
  }

  assert {
    condition     = length(databricks_sql_endpoint.this) == 1
    error_message = "A dedicated SQL warehouse must be created when warehouse_id is not provided."
  }
}

# An existing warehouse is reused instead of creating a new one.
run "plan_existing_warehouse" {
  command = plan

  variables {
    warehouse_id = "0123456789abcdef"
  }

  assert {
    condition     = length(databricks_sql_endpoint.this) == 0 && length(data.databricks_sql_warehouse.this) == 1
    error_message = "No SQL warehouse may be created when warehouse_id is provided."
  }
}
