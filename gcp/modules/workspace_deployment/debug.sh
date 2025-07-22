
SERVICE_ACCOUNT_EMAIL="alek-tf-workspace-creator@fslakehouse.iam.gserviceaccount.com"
PROJECT_ID="fslakehouse"
# Step 1: Get roles assigned to the service account
ROLES=$(gcloud projects get-iam-policy "$PROJECT_ID" \
    --flatten="bindings[].members" \
    --format="value(bindings.role)" \
    --filter="bindings.members:serviceAccount:$SERVICE_ACCOUNT_EMAIL")

gcloud iam roles describe <ROLE_ID> --format="value(includedPermissions)"
for ROLE in $ROLES; do
    echo "Role: $ROLE"
    for perm in $(gcloud iam roles describe "$ROLE" --format="value(includedPermissions)" | tr ';' '\n'); do
        echo "$perm"
    done
done
