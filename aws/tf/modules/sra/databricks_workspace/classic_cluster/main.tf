# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster

# Cluster Version
data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

# Cluster Creation
resource "databricks_cluster" "example" {
  cluster_name            = "Shared Classic Compute Plane Cluster"
  data_security_mode      = "USER_ISOLATION"
  spark_version           = data.databricks_spark_version.latest_lts.id
<<<<<<< HEAD
<<<<<<< HEAD
  node_type_id            = "m5n.large"
=======
  node_type_id            = "i3.xlarge"
>>>>>>> 8eced5b (fix(aws) update naming convention of modules, update test, add required terraform provider)
=======
  node_type_id            = "i3.large"
>>>>>>> 68bb11e (Downsized AWS & AWS Gov classic cluster instance type)
  autotermination_minutes = 10

  autoscale {
    min_workers = 1
    max_workers = 2
  }

<<<<<<< HEAD
  aws_attributes {
    availability           = "ON_DEMAND"
    ebs_volume_count       = 1
    ebs_volume_size        = 32  # Size in GB, adjust as needed
    ebs_volume_type        = "GENERAL_PURPOSE_SSD"
  }

=======
>>>>>>> 8eced5b (fix(aws) update naming convention of modules, update test, add required terraform provider)
  # Derby Metastore configs
  spark_conf = {
    "spark.hadoop.datanucleus.autoCreateTables" : "true",
    "spark.hadoop.datanucleus.autoCreateSchema" : "true",
    "spark.hadoop.javax.jdo.option.ConnectionDriverName" : "org.apache.derby.jdbc.EmbeddedDriver",
    "spark.hadoop.javax.jdo.option.ConnectionPassword" : "hivepass",
    "spark.hadoop.javax.jdo.option.ConnectionURL" : "jdbc:derby:memory:myInMemDB;create=true",
    "spark.sql.catalogImplementation" : "hive",
    "spark.hadoop.javax.jdo.option.ConnectionUserName" : "hiveuser",
    "spark.hadoop.datanucleus.fixedDatastore" : "false"
  }

  # Custom Tags
  custom_tags = {
    "Project" = var.resource_prefix
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 8eced5b (fix(aws) update naming convention of modules, update test, add required terraform provider)
