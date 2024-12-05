# Variables
PLATFORM=azure
ENV=dev
TERRAFORM_DIR=./$(PLATFORM)/tf
VARS="./../$(ENV).tfvars"

# Default target
default: help

# Help target
help:
	@echo "Available targets:"
	@echo "  lint                - Run TFLint on Terraform files."
	@echo "  terraform-plan      - Generate and show an execution plan."
	@echo "  terraform-apply     - Build or change infrastructure."
	@echo "  terraform-destroy   - Destroy Terraform-managed infrastructure."
	@echo "  help                - Show this help message."

# TFLint target
lint:
	tflint --init
	tflint -f compact --minimum-failure-severity=error --recursive

# Terraform targets
terraform-plan:
	terraform plan -chdir=$(TERRAFORM_DIR) -var-file=$(VARS)

terraform-apply:
	terraform apply -chdir=$(TERRAFORM_DIR) -var-file=$(VARS)

terraform-destroy:
	terraform destroy -chdir=$(TERRAFORM_DIR) -var-file=$(VARS)
