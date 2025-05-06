resource "databricks_job" "this" {
  name = "System Tables"

  dynamic "task" {
    for_each = local.alerts
    content {
      task_key = task.value

      sql_task {
        warehouse_id = local.warehouse_id
        alert {
          alert_id = databricks_sql_alert.alert[task.value].id

          dynamic "subscriptions" {
            for_each = var.alert_emails
            content {
              user_name = subscriptions.value
            }
          }
        }
      }
    }
  }

  schedule {
    quartz_cron_expression = "1 1 * * * ?"
    timezone_id            = "UTC"
  }

  tags = {
    project = "system-tables"
    owner   = data.databricks_current_user.me.user_name
  }
}