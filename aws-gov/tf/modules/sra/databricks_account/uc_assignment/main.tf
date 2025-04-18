# Metastore Assignment

resource "databricks_metastore_assignment" "default_metastore" {
<<<<<<< HEAD
  workspace_id = var.workspace_id
  metastore_id = var.metastore_id
=======
  workspace_id         = var.workspace_id
  metastore_id         = var.metastore_id
>>>>>>> fc4eee5 ([aws-gov] fix(aws-gov) update naming convention of modules, update test, add required terraform provider)
}