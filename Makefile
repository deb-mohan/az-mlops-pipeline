# Azure MLOps Infrastructure - Makefile
# Developer-friendly commands for infrastructure management

# .PHONY declarations
.PHONY: help setup bootstrap init-dev init-test init-prod plan apply destroy validate fmt lint clean quickstart check-tools

# Help target (default)
help:
	@echo ""
	@echo "Azure MLOps Infrastructure - Available Commands"
	@echo ""
	@echo "Setup Commands:"
	@echo "  make setup              Install all required development tools"
	@echo "  make bootstrap          Create Azure backend storage for Terraform state (default: eastus)
	@echo "  make bootstrap LOCATION=westus2  Bootstrap with custom location""
	@echo "  make quickstart ENV=dev Complete setup in one command (setup + bootstrap + init)"
	@echo "  make quickstart ENV=dev LOCATION=westus2  Quickstart with custom location"
	@echo ""
	@echo "Environment Initialization:"
	@echo "  make init-dev           Initialize Terraform for dev environment"
	@echo "  make init-test          Initialize Terraform for test environment"
	@echo "  make init-prod          Initialize Terraform for prod environment"
	@echo ""
	@echo "Terraform Operations:"
	@echo "  make plan ENV=<env>     Run terraform plan for specified environment"
	@echo "  make apply ENV=<env>    Run terraform apply for specified environment"
	@echo "  make destroy ENV=<env>  Run terraform destroy for specified environment (with confirmation)"
	@echo ""
	@echo "Code Quality:"
	@echo "  make validate           Validate Terraform configuration"
	@echo "  make fmt                Format Terraform files"
	@echo "  make lint               Run TFLint on Terraform files"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean              Remove local Terraform state and cache files"
	@echo ""
	@echo "Examples:"
	@echo "  make quickstart ENV=dev"
	@echo "  make plan ENV=dev"
	@echo "  make apply ENV=test"
	@echo ""

# Tool prerequisite checking
check-tools:
	@command -v terraform >/dev/null 2>&1 || { echo "✗ terraform not found. Run 'make setup' first."; exit 1; }
	@command -v tflint >/dev/null 2>&1 || { echo "✗ tflint not found. Run 'make setup' first."; exit 1; }
	@command -v az >/dev/null 2>&1 || { echo "✗ az (Azure CLI) not found. Run 'make setup' first."; exit 1; }
	@command -v func >/dev/null 2>&1 || { echo "✗ func (Azure Functions Core Tools) not found. Run 'make setup' first."; exit 1; }

# Setup target
setup:
	@echo "Running setup script..."
	@bash scripts/setup-tools.sh

# Bootstrap target
bootstrap: check-tools
	@echo "Running bootstrap script..."
	@bash scripts/bootstrap-backend.sh $(LOCATION)

# Init-dev target
init-dev: check-tools
	@echo "Initializing dev environment..."
	@bash scripts/init-env.sh dev

# Init-test target
init-test: check-tools
	@echo "Initializing test environment..."
	@bash scripts/init-env.sh test

# Init-prod target
init-prod: check-tools
	@echo "Initializing prod environment..."
	@bash scripts/init-env.sh prod

# Plan target with ENV validation
plan: check-tools
	@if [ -z "$(ENV)" ]; then \
		echo "✗ ENV parameter is required"; \
		echo ""; \
		echo "Usage: make plan ENV=<environment>"; \
		echo "Example: make plan ENV=dev"; \
		exit 1; \
	fi
	@bash scripts/terraform-cmd.sh plan ENV=$(ENV)

# Apply target with ENV validation
apply: check-tools
	@if [ -z "$(ENV)" ]; then \
		echo "✗ ENV parameter is required"; \
		echo ""; \
		echo "Usage: make apply ENV=<environment>"; \
		echo "Example: make apply ENV=dev"; \
		exit 1; \
	fi
	@bash scripts/terraform-cmd.sh apply ENV=$(ENV)

# Destroy target with ENV validation
destroy: check-tools
	@if [ -z "$(ENV)" ]; then \
		echo "✗ ENV parameter is required"; \
		echo ""; \
		echo "Usage: make destroy ENV=<environment>"; \
		echo "Example: make destroy ENV=dev"; \
		exit 1; \
	fi
	@bash scripts/terraform-cmd.sh destroy ENV=$(ENV)

# Validate target
validate: check-tools
	@bash scripts/terraform-cmd.sh validate

# Format target
fmt: check-tools
	@bash scripts/terraform-cmd.sh fmt

# Lint target
lint: check-tools
	@echo "Running TFLint..."
	@cd infrastructure/terraform && tflint

# Clean target
clean:
	@echo "Cleaning local Terraform files..."
	@find infrastructure/terraform -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find infrastructure/terraform -type f -name "*.tfstate" -exec rm -f {} + 2>/dev/null || true
	@find infrastructure/terraform -type f -name "*.tfstate.backup" -exec rm -f {} + 2>/dev/null || true
	@find infrastructure/terraform -type f -name ".terraform.lock.hcl" -exec rm -f {} + 2>/dev/null || true
	@echo "✓ Clean complete"

# Quickstart target
quickstart:
	@if [ -z "$(ENV)" ]; then \
		echo "✗ ENV parameter is required"; \
		echo ""; \
		echo "Usage: make quickstart ENV=<environment>"; \
		echo "Example: make quickstart ENV=dev"; \
		exit 1; \
	fi
	@echo "Starting quickstart for $(ENV) environment..."
	@echo ""
	@$(MAKE) setup
	@$(MAKE) bootstrap
	@$(MAKE) init-$(ENV)
	@echo ""
	@echo "✓ Quickstart complete!"
	@echo ""
	@echo "Next steps:"
	@echo "  make plan ENV=$(ENV)"
	@echo "  make apply ENV=$(ENV)"
	@echo ""
