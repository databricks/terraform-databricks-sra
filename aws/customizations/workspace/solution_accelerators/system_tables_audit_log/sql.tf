locals {
  # Maps the comparison operators in queries_and_alerts.json to the databricks_alert condition enum.
  alert_op_map = {
    "!=" = "NOT_EQUAL"
    "<"  = "LESS_THAN"
    "<=" = "LESS_THAN_OR_EQUAL"
    "==" = "EQUAL"
    ">"  = "GREATER_THAN"
    ">=" = "GREATER_THAN_OR_EQUAL"
  }
  warehouse_id = var.warehouse_id == "" ? databricks_sql_endpoint.this[0].id : data.databricks_sql_warehouse.this[0].id
}

resource "databricks_sql_endpoint" "this" {
  count            = var.warehouse_id == "" ? 1 : 0
  warehouse_type   = "PRO"
  name             = "System Tables"
  cluster_size     = "Small"
  max_num_clusters = 1
  auto_stop_mins   = 10
}

data "databricks_sql_warehouse" "this" {
  count = var.warehouse_id == "" ? 0 : 1
  id    = var.warehouse_id
}

resource "databricks_query" "query" {
  for_each     = local.queries
  warehouse_id = local.warehouse_id
  display_name = local.data_map[each.value].name
  query_text   = local.data_map[each.value].query
  description  = local.data_map[each.value].description
  parent_path  = trimsuffix(databricks_directory.this[local.data_map[each.value].parent].path, "/")

  tags = [
    "system-tables",
  ]
}

resource "databricks_alert" "alert" {
  for_each             = local.alerts
  query_id             = databricks_query.query[each.value].id
  display_name         = local.data_map[each.value].alert.name
  parent_path          = trimsuffix(databricks_directory.this[local.data_map[each.value].alert.parent].path, "/")
  seconds_to_retrigger = local.data_map[each.value].alert.rearm
  custom_body          = local.data_map[each.value].alert.options.custom_body
  custom_subject       = local.data_map[each.value].alert.options.custom_subject

  condition {
    op = local.alert_op_map[local.data_map[each.value].alert.options.op]
    operand {
      column {
        name = local.data_map[each.value].alert.options.column
      }
    }
    threshold {
      value {
        double_value = tonumber(local.data_map[each.value].alert.options.value)
      }
    }
  }
}