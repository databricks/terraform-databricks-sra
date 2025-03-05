resource "databricks_sql_endpoint" "new" {
<<<<<<< HEAD
<<<<<<<< HEAD:aws/tf/modules/sra/security_analysis_tool/common/sql_warehouse.tf
=======
<<<<<<<< HEAD:aws/customizations/workspace/solution_accelerators/security_analysis_tool/common/sql_warehouse.tf
<<<<<<<< HEAD:aws/tf/modules/sra/security_analysis_tool/common/sql_warehouse.tf
========
>>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update):aws/tf/modules/sra/security_analysis_tool/common/sql_warehouse.tf
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
  count                     = var.sqlw_id == "new" ? 1 : 0
  name                      = "SAT Warehouse"
  cluster_size              = "Small"
  max_num_clusters          = 1
<<<<<<< HEAD
=======
<<<<<<<< HEAD:aws/customizations/workspace/solution_accelerators/security_analysis_tool/common/sql_warehouse.tf
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
========
  count            = var.sqlw_id == "new" ? 1 : 0
  name             = "SAT Warehouse"
  cluster_size     = "Small"
>>>>>>>> b3e4c6f (aws simplicity update):aws/customizations/workspace/solution_accelerators/security_analysis_tool/common/sql_warehouse.tf
<<<<<<< HEAD
=======
========
>>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update):aws/tf/modules/sra/security_analysis_tool/common/sql_warehouse.tf
>>>>>>> d598b99 (tf linting, sat integration, audit logs reintegration, additional resource for deployment name, and readme update)
  enable_serverless_compute = true

  tags {
    custom_tags {
      key   = "owner"
      value = data.databricks_current_user.me.alphanumeric
    }
  }
}

data "databricks_sql_warehouse" "old" {
  count = var.sqlw_id == "new" ? 0 : 1
  id    = var.sqlw_id
}
