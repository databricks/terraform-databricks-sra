//generate a random string as the prefix for GCP resources, to ensure uniqueness
resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix = "unity${random_string.naming.result}"
}



resource "google_storage_bucket" "unity_metastore" {
  name          = "${local.prefix}-metastore"
  location      = var.location
  force_destroy = true
}

resource "google_storage_bucket" "ext_bucket" {
  name          = "${local.prefix}-ext"
  location      = var.location
  force_destroy = true
}

resource "databricks_metastore" "this" {
  provider = databricks.workspace
  name          = "unity-catalog-${var.resource_prefix}"
  storage_root  = "gs://${google_storage_bucket.unity_metastore.name}"
  force_destroy = true
}

resource "databricks_metastore_data_access" "first" {
  provider = databricks.workspace
  metastore_id = databricks_metastore.this.id
  databricks_gcp_service_account {}
  name       = "the-keys"
  is_default = true
  depends_on = [ databricks_metastore_assignment.this ]
}

resource "google_storage_bucket_iam_member" "unity_sa_admin" {
  depends_on = [ google_storage_bucket.unity_metastore ]
  bucket = google_storage_bucket.unity_metastore.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${databricks_metastore_data_access.first.databricks_gcp_service_account[0].email}"
}

resource "google_storage_bucket_iam_member" "unity_sa_reader" {
  depends_on = [google_storage_bucket.unity_metastore ]
  bucket = google_storage_bucket.unity_metastore.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${databricks_metastore_data_access.first.databricks_gcp_service_account[0].email}"
}



resource "databricks_metastore_assignment" "this" {
  depends_on = [databricks_metastore.this  ]
  provider = databricks.workspace
  count                = length(var.databricks_workspace_ids)
  workspace_id         = var.databricks_workspace_ids[count.index]
  metastore_id         = databricks_metastore.this.id
  
  default_catalog_name = "hive_metastore"
}

resource "databricks_metastore_assignment" "external" {
  depends_on = [ databricks_metastore.this ]
  provider = databricks.workspace
  count                = length(var.databricks_workspace_ids_for_existing_metastore)
  workspace_id         = var.databricks_workspace_ids_for_existing_metastore[count.index]
  metastore_id         = var.existing_metastore_id
  
  default_catalog_name = "hive_metastore"
}

//Storage credentials
resource "databricks_storage_credential" "ext" {
  depends_on = [ databricks_metastore_assignment.this ]
  provider = databricks.workspace
  name = "the-creds"
  databricks_gcp_service_account {}
}

resource "google_storage_bucket_iam_member" "ext_admin" {
  depends_on = [ google_storage_bucket.ext_bucket,databricks_storage_credential.ext ]
  bucket = google_storage_bucket.ext_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${databricks_storage_credential.ext.databricks_gcp_service_account[0].email}"
}

resource "google_storage_bucket_iam_member" "ext_reader" {
  depends_on = [ google_storage_bucket.ext_bucket,databricks_storage_credential.ext ]
  bucket = google_storage_bucket.ext_bucket.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${databricks_storage_credential.ext.databricks_gcp_service_account[0].email}"
}

// External Location
resource "databricks_external_location" "some" {
  depends_on = [ databricks_storage_credential.ext,google_storage_bucket_iam_member.ext_admin,google_storage_bucket.ext_bucket,google_storage_bucket_iam_member.ext_reader ]
  provider = databricks.workspace
  name = "the-ext-location"
  url  = "gs://${google_storage_bucket.ext_bucket.name}"

  credential_name = databricks_storage_credential.ext.id
  comment         = "Managed by TF"
}

// External Location Grant
resource "databricks_grants" "data_example" {
  depends_on = [ databricks_external_location.some ]
  provider = databricks.workspace
  external_location = databricks_external_location.some.id
  grant {
    principal  = var.data_access
    privileges = ["ALL_PRIVILEGES"]
  }
}


