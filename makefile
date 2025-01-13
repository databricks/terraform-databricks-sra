# Variables
PLATFORM=azure
ENV=dev
TERRAFORM_DIR=./$(PLATFORM)/tf
VARS="./../../$(ENV).tfvars"
WORKSPACE="$(ENV)"
BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)

# Default target
default: help

# Help
help:
	@echo "Available targets:"
	@echo "  lint                - Run TFLint on Terraform files."
	@echo "  terraform-plan      - Generate and show an execution plan."
	@echo "  terraform-apply     - Build or change infrastructure."
	@echo "  terraform-destroy   - Destroy Terraform-managed infrastructure."
	@echo "  help                - Show this help message."


# tflint
check-tflint:
	@if ! command -v tflint >/dev/null 2>&1; then \
		echo "Error: tflint is not installed. Please install it before running this Makefile."; \
		exit 1; \
	fi

tflint-init: check-tflint
	tflint --init

lint: check-tflint prep
	tflint -f compact --minimum-failure-severity=error --recursive

# Terraform
set-platform:
	@if [ -z $(PLATFORM) ]; then \
		echo "$(BOLD)$(RED)PLATFORM was not set$(RESET)"; \
		ERROR=1; \
	 fi
	@if [ ! -z $${ERROR} ] && [ $${ERROR} -eq 1 ]; then \
		echo "$(BOLD)Example usage: \`PLATFORM=azure ENV=dev make plan\`$(RESET)"; \
		exit 1; \
	 fi

prep: set-platform
	terraform -chdir=$(TERRAFORM_DIR) init
	@echo "$(BOLD)Switching to workspace $(WORKSPACE)$(RESET)"
	terraform -chdir=$(TERRAFORM_DIR) workspace select -or-create $(WORKSPACE)

plan: prep
	terraform -chdir=$(TERRAFORM_DIR) plan -var-file=$(VARS)

apply: prep
	terraform -chdir=$(TERRAFORM_DIR) apply -var-file=$(VARS)

destroy: prep
	terraform -chdir=$(TERRAFORM_DIR) destroy -var-file=$(VARS)
