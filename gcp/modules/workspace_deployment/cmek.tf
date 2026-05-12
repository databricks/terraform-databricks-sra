# Create keyring (only when we own the CMEK).
resource "google_kms_key_ring" "databricks_key_ring" {
  provider = google
  count    = (var.use_cmek && !var.use_existing_cmek) ? 1 : 0
  name     = "${var.keyring_name}-${local.deployment_suffix}"
  location = var.google_region
}

# Create KMS key used for workspace encryption.
resource "google_kms_crypto_key" "databricks_key" {
  provider        = google
  count           = (var.use_cmek && !var.use_existing_cmek) ? 1 : 0
  name            = "${var.key_name}-${local.deployment_suffix}"
  key_ring        = google_kms_key_ring.databricks_key_ring[0].id
  purpose         = "ENCRYPT_DECRYPT"
  rotation_period = "31536000s" # 1 year (must be greater than 1 day)
}

# Register the CMEK with Databricks.
resource "databricks_mws_customer_managed_keys" "this" {
  provider   = databricks.accounts
  count      = (var.use_cmek && !var.use_existing_cmek) ? 1 : 0
  account_id = var.databricks_account_id

  gcp_key_info {
    kms_key_id = var.cmek_resource_id != "" ? var.cmek_resource_id : google_kms_crypto_key.databricks_key[0].id
  }

  use_cases = ["STORAGE", "MANAGED", "MANAGED_SERVICES"]

  lifecycle {
    ignore_changes = all
  }
}
