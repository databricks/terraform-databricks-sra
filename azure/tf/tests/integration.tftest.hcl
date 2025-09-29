test {
  parallel = true
}

variables {
  databricks_host = run.test_initializer.outputs.spoke_workspace_info[1]
  sra_tag         = "SRA Test Suite"
  catalog_name    = run.test_initializer.outputs.spoke_workspace_catalog
  open_test_job   = false
  environment = {
    DATABRICKS_HOST          = run.test_initializer.outputs.spoke_workspace_info[1]
    BUNDLE_VAR_node_type_id  = run.classic_cluster_spoke.node_type_id
    BUNDLE_VAR_spark_version = run.classic_cluster_spoke.spark_version
    BUNDLE_VAR_sra_tag       = var.sra_tag
    BUNDLE_VAR_catalog_name  = var.catalog_name
    BUNDLE_VAR_cluster_id    = run.classic_cluster_spoke.cluster_id
  }
}

# Run the test initializer to get outputs from the local state in the cloud directory
run "test_initializer" {
  state_key = "test_initializer"
  command   = apply
  module {
    source = "../../common/tests/test_initializer"
  }
}

# Provision a small autoscaling classic cluster suitable for test jobs
# Covers:
# - Creating a classic cluster
run "classic_cluster_spoke" {
  state_key = "classic_cluster_spoke"
  command   = apply
  module {
    source = "../../common/tests/classic_cluster"
  }
  variables {
    tags = {
      SRA = var.sra_tag
    }
  }
}

# Deploy the bundle located at `sra_bundle_test/bundle` via `databricks bundle deploy --auto-approve` and destroy it on cleanup
# Covers:
# - Creating jobs, notebooks, experiments, models, lakebase
run "bundle_deploy" {
  state_key = "bundle_deploy"
  command   = apply
  module {
    source = "../../common/tests/sra_bundle_test"
  }
}

# Run the Spark basic job
# Covers:
# - Running a Spark basic job
# - Creating a UC Schema
# - Creating a UC Table
# - Writing to a UC Table
# - Reading from a UC Table
run "spark_basic" {
  state_key = "bundle_spark_basic"
  command   = apply
  module {
    source = "../../common/tests/bundle_run"
  }
  variables {
    bundle_job_name = "spark_basic"
    working_dir     = run.bundle_deploy.working_dir
  }
}

# Run the ML workflow classic job
# Covers:
# - Creating a UC Table
# - Writing to a UC Table
# - Reading from a UC Table
# - Registering a model (tests blob endpoints for storage accounts)
# - Access to sample data (nyc taxi data)

run "ml_workflow_classic" {
  state_key = "bundle_ml_workflow_classic"
  command   = apply
  module {
    source = "../../common/tests/bundle_run"
  }
  variables {
    bundle_job_name = "ml_workflow_classic"
    working_dir     = run.bundle_deploy.working_dir
  }
}

# Run the ML cleanup classic job
# Covers:
# - Deleting a model from classic
run "ml_cleanup_classic" {
  state_key = "bundle_ml_cleanup_classic"
  command   = apply
  module {
    source = "../../common/tests/bundle_run"
  }
  variables {
    depends         = run.ml_workflow_classic.depends
    bundle_job_name = "model_cleanup_classic"
    working_dir     = run.bundle_deploy.working_dir
    open_test_job   = false
  }
}

# Run the ML workflow serverless job
# Covers (from serverless):
# - Creating a UC Table
# - Writing to a UC Table
# - Reading from a UC Table
# - Registering a model (tests blob endpoints for storage accounts)
# - Access to sample data (nyc taxi data)

run "ml_workflow_serverless" {
  state_key = "bundle_ml_workflow_serverless"
  command   = apply
  module {
    source = "../../common/tests/bundle_run"
  }
  variables {
    bundle_job_name = "ml_workflow_serverless"
    working_dir     = run.bundle_deploy.working_dir
  }
}

# Run the ML cleanup serverless job
# Covers:
# - Deleting a model from serverless
run "ml_cleanup_serverless" {
  state_key = "bundle_ml_cleanup_serverless"
  command   = apply
  module {
    source = "../../common/tests/bundle_run"
  }
  variables {
    depends         = run.ml_workflow_serverless.depends
    bundle_job_name = "model_cleanup_serverless"
    working_dir     = run.bundle_deploy.working_dir
    open_test_job   = false
  }
}


# Run the Lakebase connectivity job
# Covers:
# - Connecting to Lakebase from classic
run "lakebase_connectivity" {
  state_key = "bundle_lakebase_connectivity"
  command   = apply
  module {
    source = "../../common/tests/bundle_run"
  }
  variables {
    bundle_job_name = "lakebase"
    working_dir     = run.bundle_deploy.working_dir
  }
}
