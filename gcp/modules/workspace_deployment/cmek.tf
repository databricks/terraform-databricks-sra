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
  rotation_period = "7776000s" # 90 days (CIS-aligned; must be greater than 1 day)

  # Protect the CMEK from accidental deletion — destroying it would render all
  # data encrypted under it permanently unrecoverable. NOTE: this also blocks
  # `terraform destroy`; comment out prevent_destroy if you intend to tear the
  # workspace down.
  lifecycle {
    prevent_destroy = true
  }
}

# Register the CMEK with Databricks.
resource "databricks_mws_customer_managed_keys" "this" {
  provider   = databricks.accounts
  count      = (var.use_cmek && !var.use_existing_cmek) ? 1 : 0
  account_id = var.databricks_account_id

  gcp_key_info {
    kms_key_id = var.cmek_resource_id != "" ? var.cmek_resource_id : google_kms_crypto_key.databricks_key[0].id
  }

  # Valid use cases are STORAGE and MANAGED_SERVICES. ("MANAGED" was previously
  # listed here but is not a documented value and can be rejected by the API.)
  use_cases = ["STORAGE", "MANAGED_SERVICES"]

  # NOTE: ignore_changes = all avoids perpetual diffs from server-computed
  # fields, but it also suppresses drift on use_cases/gcp_key_info. Narrow this
  # if you need Terraform to reconcile CMEK changes after creation.
  lifecycle {
    ignore_changes = all
  }
}
