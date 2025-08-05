test {
  parallel = true
}

variables {
  tags = {
    SRA = "Local SRA Test"
  }
}

run "test_initializer" {
  state_key = "test_initializer"
  command   = apply
  module {
    source = "../../common/tests/test_initializer"
  }
}

run "classic_cluster" {
  state_key = "classic_cluster"
  command   = apply
  module {
    source = "../../common/tests/classic_cluster"
  }
  variables {
    databricks_host = run.test_initializer.outputs.workspace_host
  }
}

run "spark_classic" {
  state_key = "spark_classic"
  command   = apply
  module {
    source = "../../common/tests/spark"
  }
  variables {
    databricks_host = run.test_initializer.outputs.workspace_host
    cluster_id      = run.classic_cluster.cluster_id
  }
}

run "spark_serverless" {
  state_key = "spark_serverless"
  command   = apply
  module {
    source = "../../common/tests/spark"
  }
  variables {
    databricks_host = run.test_initializer.outputs.workspace_host
    cluster_id      = null # This makes the job run on serverless
  }
}
