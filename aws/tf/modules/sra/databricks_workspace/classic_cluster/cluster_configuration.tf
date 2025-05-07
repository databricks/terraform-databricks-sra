// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster

// Cluster Version
# data "databricks_spark_version" "latest_lts" {
#   long_term_support = true
# }

# // Cluster Creation
# resource "databricks_cluster" "example" {
#   cluster_name            = "Shared Classic Compute Plane Cluster"
#   data_security_mode      = "USER_ISOLATION"
#   spark_version           = data.databricks_spark_version.latest_lts.id
#   node_type_id            = "i3.xlarge"
#   autotermination_minutes = 10

#   autoscale {
#     min_workers = 1
#     max_workers = 2
#   }

#   // Derby Metastore configs
#   spark_conf = {
#     "spark.hadoop.datanucleus.autoCreateTables" : "true",
#     "spark.hadoop.datanucleus.autoCreateSchema" : "true",
#     "spark.hadoop.javax.jdo.option.ConnectionDriverName" : "org.apache.derby.jdbc.EmbeddedDriver",
#     "spark.hadoop.javax.jdo.option.ConnectionPassword" : "hivepass",
#     "spark.hadoop.javax.jdo.option.ConnectionURL" : "jdbc:derby:memory:myInMemDB;create=true",
#     "spark.sql.catalogImplementation" : "hive",
#     "spark.hadoop.javax.jdo.option.ConnectionUserName" : "hiveuser",
#     "spark.hadoop.datanucleus.fixedDatastore" : "false"
#   }

#   // Custom Tags
#   custom_tags = {
#     "Project" = var.resource_prefix
#   }
# }