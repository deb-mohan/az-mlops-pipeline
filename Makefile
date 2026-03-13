# Azure MLOps Infrastructure - Makefile
# Developer-friendly commands for infrastructure management

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
RED := \033[0;31m
NC := \033[0m # No Color

# 6.2: .PHONY declarations
.PHONY: help setup bootstrap init-dev init-test init-prod plan apply destroy validate fmt lint clean quickstart check-tools

# 6.3: Help target (default)
help:
	@echo ""
	@echo "$(BLUE)Azure MLOps Infrastructure - Available Commands$(NC)"
	@echo ""
	@echo "$(GREEN)Setup Commands:$(NC)"
	@echo "  make setup              Install all required development tools"
	@echo "  make bootstrap          Create Azure backend storage for Terraform state"
	@echo "  make quickstart ENV=dev Complete setup in one command (setup + bootstrap + init)"
	@echo ""
	@echo "$(GREEN)Environment Initialization:$(NC)"
	@echo "  make init-dev           Initialize Terraform for dev environment"
	@echo "  make init-test          Initialize Terraform for test environment"
	@echo "  make init-prod          Initialize Terraform for prod environment"
	@echo ""
	@echo "$(GREEN)Terraform Operations:$(NC)"
	@echo "  make plan ENV=<env>     Run terraform plan for specified environment"
	@echo "  make apply ENV=<env>    Run terraform apply for specified environment"
	@echo "  make destroy ENV=<env>  Run terraform destroy for specified environment (with confirmation)"
	@echo ""
	@echo "$(GREEN)Code Quality:$(NC)"
	@echo "  make validate           Validate Terraform configuration"
	@echo "  make fmt                Format Terraform files"
	@echo "  make lint               Run TFLint on Terraform files"
	@echo ""
	@echo "$(GREEN)Utilities:$(NC)"
	@echo "  make clean              Remove local Terraform state and cache files"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make quickstart ENV=dev"
	@echo "  make plan ENV=dev"
	@echo "  make apply ENV=test"
	@echo ""

# 6.17: Tool prerequisite checking
check-tools:
	@command -v terraform >/dev/null 2>&1 || { echo "$(RED)✗$(NC) terraform not found. Run 'make setup' first."; exit 1; }
	@command -v tflint >/dev/null 2>&1 || { echo "$(RED)✗$(NC) tflint not found. Run 'make setup' first."; exit 1; }
	@command -v az >/dev/null 2>&1 || { echo "$(RED)✗$(NC) az (Azure CLI) not found. Run 'make setup' first."; exit 1; }
	@command -v func >/dev/null 2>&1 || { echo "$(RED)✗$(NC) func (Azure Functions Core Tools) not found. Run 'make setup' first."; exit 1; }

# 6.4: Setup target
setup:
	@echo "$(BLUE)Running setup script...$(NC)"
	@bash scripts/setup-tools.sh

# 6.5: Bootstrap target
bootstrap: check-tools
	@echo "$(BLUE)Running bootstrap script...$(NC)"
	@bash scripts/bootstrap-backend.sh

# 6.6: Init-dev target
init-dev: check-tools
	@echo "$(BLUE)Initializing dev environment...$(NC)"
	@bash scripts/init-env.sh dev

# 6.7: Init-test target
init-test: check-tools
	@echo "$(BLUE)Initializing test environment...$(NC)"
	@bash scripts/init-env.sh test

# 6.8: Init-prod target
init-prod: check-tools
	@echo "$(BLUE)Initializing prod environment...$(NC)"
	@bash scripts/init-env.sh prod

# 6.9: Plan target with ENV validation
plan: check-tools
	@if [ -z "$(ENV)" ]; then \
		echo "$(RED)✗$(NC) ENV parameter is required"; \
		echo ""; \
		echo "Usage: make plan ENV=<environment>"; \
		echo "Example: make plan ENV=dev"; \
		exit 1; \
	fi
	@bash scripts/terraform-cmd.sh plan ENV=$(ENV)

# 6.10: Apply target with ENV validation
apply: check-tools
	@if [ -z "$(ENV)" ]; then \
		echo "$(RED)✗$(NC) ENV parameter is required"; \
		echo ""; \
		echo "Usage: make apply ENV=<environment>"; \
		echo "Example: make apply ENV=dev"; \
		exit 1; \
	fi
	@bash scripts/terraform-cmd.sh apply ENV=$(ENV)

# 6.11: Destroy target with ENV validation
destroy: check-tools
	@if [ -z "$(ENV)" ]; then \
		echo "$(RED)✗$(NC) ENV parameter is required"; \
		echo ""; \
		echo "Usage: make destroy ENV=<environment>"; \
		echo "Example: make destroy ENV=dev"; \
		exit 1; \
	fi
	@bash scripts/terraform-cmd.sh destroy ENV=$(ENV)

# 6.12: Validate target
validate: check-tools
	@bash scripts/terraform-cmd.sh validate

# 6.13: Format target
fmt: check-tools
	@bash scripts/terraform-cmd.sh fmt

# 6.14: Lint target
lint: check-tools
	@echo "$(BLUE)Running TFLint...$(NC)"
	@cd infrastructure/terraform && tflint

# 6.15: Clean target
clean:
	@echo "$(YELLOW)Cleaning local Terraform files...$(NC)"
	@find infrastructure/terraform -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find infrastructure/terraform -type f -name "*.tfstate" -exec rm -f {} + 2>/dev/null || true
	@find infrastructure/terraform -type f -name "*.tfstate.backup" -exec rm -f {} + 2>/dev/null || true
	@find infrastructure/terraform -type f -name ".terraform.lock.hcl" -exec rm -f {} + 2>/dev/null || true
	@echo "$(GREEN)✓$(NC) Clean complete"

# 6.16: Quickstart target
quickstart:
	@if [ -z "$(ENV)" ]; then \
		echo "$(RED)✗$(NC) ENV parameter is required"; \
		echo ""; \
		echo "Usage: make quickstart ENV=<environment>"; \
		echo "Example: make quickstart ENV=dev"; \
		exit 1; \
	fi
	@echo "$(BLUE)Starting quickstart for $(ENV) environment...$(NC)"
	@echo ""
	@$(MAKE) setup
	@$(MAKE) bootstrap
	@$(MAKE) init-$(ENV)
	@echo ""
	@echo "$(GREEN)✓ Quickstart complete!$(NC)"
	@echo ""
	@echo "Next steps:"
	@echo "  make plan ENV=$(ENV)"
	@echo "  make apply ENV=$(ENV)"
	@echo ""
