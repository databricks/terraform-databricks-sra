

resource "databricks_mws_private_access_settings" "pas" {
 count = var.use_existing_pas ? 0 : 1
 provider       = databricks.accounts
 private_access_settings_name = "pas-${random_string.suffix.result}"
 region                       = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
 public_access_enabled        = true
 private_access_level         = "ACCOUNT"
}

resource "databricks_mws_workspaces" "this" {
  provider       = databricks.accounts
  account_id     = var.databricks_account_id
  workspace_name = var.workspace_name
  location       = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
  cloud_resource_container {
    gcp {
      project_id = var.google_project
    }
  }
  private_access_settings_id = var.use_existing_pas? var.existing_pas_id:databricks_mws_private_access_settings.pas[0].private_access_settings_id
  network_id = databricks_mws_networks.network_config.network_id

  storage_customer_managed_key_id = var.use_existing_cmek ? var.cmek_resource_id : databricks_mws_customer_managed_keys.this[0].customer_managed_key_id
  managed_services_customer_managed_key_id = var.use_existing_cmek ? var.cmek_resource_id : databricks_mws_customer_managed_keys.this[0].customer_managed_key_id

  # this makes sure that the NAT is created for outbound traffic before creating the workspace
  # not needed if the workspace uses backend PSC (recommended)
  #depends_on = [ databricks_mws_customer_managed_keys.this]
}

# Cleanup resource to handle Databricks-managed firewall rules
# This prevents the "network in use by firewall rule" error during destroy
resource "null_resource" "workspace_firewall_cleanup" {
  # This resource is created after the workspace but destroyed before it
  depends_on = [databricks_mws_workspaces.this]
  
  triggers = {
    workspace_id = databricks_mws_workspaces.this.workspace_id
    network_name = google_compute_network.dbx_private_vpc.name
    workspace_url = databricks_mws_workspaces.this.workspace_url
  }
  
  provisioner "local-exec" {
    when = destroy
    command = <<-EOT
      #!/bin/bash
      set -e
      
      WORKSPACE_ID="${self.triggers.workspace_id}"
      NETWORK_NAME="${self.triggers.network_name}"
      
      echo "🧹 Cleaning up Databricks-managed firewall rules for workspace $WORKSPACE_ID"
      
      # Find firewall rules created by Databricks for this workspace
      FIREWALL_RULES=$(gcloud compute firewall-rules list \
        --filter="name:databricks-$WORKSPACE_ID*" \
        --format="value(name)" 2>/dev/null || true)
      
      if [ -n "$FIREWALL_RULES" ]; then
        echo "📋 Found Databricks-managed firewall rules:"
        echo "$FIREWALL_RULES"
        
        # Delete each firewall rule
        while IFS= read -r rule; do
          if [ -n "$rule" ]; then
            echo "🗑️  Deleting firewall rule: $rule"
            gcloud compute firewall-rules delete "$rule" --quiet 2>/dev/null || {
              echo "⚠️  Warning: Could not delete firewall rule $rule (may already be deleted)"
            }
          fi
        done <<< "$FIREWALL_RULES"
        
        echo "✅ Firewall cleanup completed"
        sleep 3  # Allow time for changes to propagate
      else
        echo "ℹ️  No Databricks-managed firewall rules found for workspace $WORKSPACE_ID"
      fi
    EOT
    
    # Set environment for gcloud authentication
    environment = {
      GOOGLE_APPLICATION_CREDENTIALS = "/Users/aleksander.callebat/Documents/Databricks/fslakehouse-a08a713a0473.json"
    }
  }
}

