
# create key ring
resource "google_kms_key_ring" "databricks_key_ring" {
    provider = google
    count = var.use_existing_cmek ? 0 : 1
    name     = "${var.keyring_name}-${random_string.suffix.result}"
    location = var.google_region
}

# create key used for encryption
resource "google_kms_crypto_key" "databricks_key" {
  provider = google
  count = var.use_existing_cmek ? 0 : 1
  name       = "${var.key_name}-${random_string.suffix.result}"
  key_ring   = google_kms_key_ring.databricks_key_ring[0].id
  purpose    = "ENCRYPT_DECRYPT"
  rotation_period = "31536000s" # Set rotation period to 1 year in seconds, need to be greater than 1 day

}

# # assign CMEK on Databricks side
resource "databricks_mws_customer_managed_keys" "this" {
        
        provider = databricks.accounts
        count = var.use_existing_cmek ? 0 : 1
        account_id   = var.databricks_account_id
        gcp_key_info {
            # kms_key_id   = var.use_existing_cmek? "projects/${var.google_project}/locations/${var.google_region}/keyRings/${var.keyring_name}-${random_string.suffix.result}/cryptoKeys/${var.key_name}-${random_string.suffix.result}": google_kms_crypto_key.databricks_key[0].id
            kms_key_id   = var.cmek_resource_id
        }
        use_cases = ["STORAGE","MANAGED","MANAGED_SERVICES"]
        lifecycle {
              ignore_changes = all
        }
}

