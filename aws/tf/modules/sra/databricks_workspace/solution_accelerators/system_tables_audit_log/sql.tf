locals {
  warehouse_id   = var.warehouse_id == "" ? databricks_sql_endpoint.this[0].id : data.databricks_sql_warehouse.this[0].id
  data_source_id = var.warehouse_id == "" ? databricks_sql_endpoint.this[0].data_source_id : data.databricks_sql_warehouse.this[0].data_source_id
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

resource "databricks_sql_query" "query" {
  for_each       = local.queries
  data_source_id = local.data_source_id
  name           = local.data_map[each.value].name
  query          = local.data_map[each.value].query
  description    = local.data_map[each.value].description
  parent         = "folders/${databricks_directory.this[local.data_map[each.value].parent].object_id}"

  tags = [
    "system-tables",
  ]
}

resource "databricks_sql_alert" "alert" {
  for_each = local.alerts
  query_id = databricks_sql_query.query[each.value].id
  name     = local.data_map[each.value].alert.name
  parent   = "folders/${databricks_directory.this[local.data_map[each.value].alert.parent].object_id}"
  rearm    = local.data_map[each.value].alert.rearm

  options {
    column         = local.data_map[each.value].alert.options.column
    op             = local.data_map[each.value].alert.options.op
    value          = local.data_map[each.value].alert.options.value
    muted          = local.data_map[each.value].alert.options.muted
    custom_body    = local.data_map[each.value].alert.options.custom_body
    custom_subject = local.data_map[each.value].alert.options.custom_subject
  }
}