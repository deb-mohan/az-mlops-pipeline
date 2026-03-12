# Azure MLOps Infrastructure

Terraform infrastructure for Azure Machine Learning Operations pipeline supporting multiple environments (dev, test, prod) and dynamic feature branch deployments.

## Overview

This project provides a DRY (Don't Repeat Yourself) Terraform infrastructure setup for Azure ML with:

- Single source of truth (main.tf) with environment-specific variable files
- Modular architecture for ML Workspace, Storage, Compute, and Networking
- Multi-environment support: dev, test, prod, and feature branches
- Quality gates with TFLint and pre-commit hooks
- Isolated state management per environment using Azure Storage backend
- Consistent resource naming with global uniqueness for storage accounts

## Prerequisites

### Required (Manual Installation)

- **Xcode Command Line Tools** (macOS only)
  ```bash
  xcode-select --install
  ```

- **Homebrew** (macOS package manager)
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

### Automated Installation

The following tools will be installed automatically by running `make setup`:

- [Terraform](https://www.terraform.io/downloads) >= 1.5 - Infrastructure as Code
- [TFLint](https://github.com/terraform-linters/tflint) - Terraform linter
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/) - Azure command-line interface
- [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local) v4 - Local function development
- [uv](https://docs.astral.sh/uv/) - Modern Python package manager
- Python dependencies (via pyproject.toml)
- Pre-commit hooks

### Future Enhancements

- **GPG for Code Signing** - See [GitHub's GPG documentation](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification) for setup instructions

## Quick Start

### Option 1: One-Command Setup (Recommended)

```bash
# Clone the repository
git clone <repo-url>
cd azure-mlops-project

# Authenticate with Azure
az login

# Run complete setup for dev environment
make quickstart ENV=dev
```

This single command will:
1. Install all required development tools
2. Create Azure backend storage for Terraform state
3. Initialize Terraform for the dev environment

### Option 2: Step-by-Step Setup

If you prefer to run each step individually:

```bash
# 1. Clone the repository
git clone <repo-url>
cd azure-mlops-project

# 2. Install development tools
make setup

# 3. Authenticate with Azure
az login

# 4. Create backend storage
make bootstrap

# 5. Initialize environment
make init-dev
```

## Usage

### Deploy to Dev Environment

```bash
# Plan changes
make plan ENV=dev

# Apply changes
make apply ENV=dev
```

### Deploy to Test Environment

```bash
# Initialize test environment (if not already done)
make init-test

# Plan and apply
make plan ENV=test
make apply ENV=test
```

### Deploy to Prod Environment

```bash
# Initialize prod environment (if not already done)
make init-prod

# Plan and apply
make plan ENV=prod
make apply ENV=prod
```

## Feature Branch Environments

For feature branch or PR preview environments:

1. Create environment configuration:
```bash
cd infrastructure/terraform/environments
cp feature.auto.tfvars.template johndoe.auto.tfvars
```

2. Edit `johndoe.auto.tfvars` and replace `<username>` with your username

3. Initialize and deploy:
```bash
# From project root
bash scripts/init-env.sh johndoe
make plan ENV=johndoe
make apply ENV=johndoe
```

## Backend Configuration and State Management

This project uses Azure Storage for Terraform state management with automated backend setup and secure authentication.

### Backend Resources

The backend bootstrap process creates the following Azure resources:

- **Resource Group**: `terraform-state-rg`
- **Storage Account**: `tfstateiemlops`
- **Container**: `tfstate`
- **Location**: `eastus` (default, configurable)

### Automated Bootstrap

Run `make bootstrap` to automatically create all backend resources. The script is idempotent and can be run multiple times safely.

```bash
# Create backend with default location (eastus)
make bootstrap

# Or specify a custom location
bash scripts/bootstrap-backend.sh westus2
```

### Secure Authentication

The backend uses **Azure CLI authentication** instead of access keys for enhanced security:

- **Local Development**: Terraform uses your Azure CLI login (`az login`)
- **CI/CD Pipelines**: Use managed identity or service principal
- **No Access Keys**: No credentials stored in plaintext files

The `.env.local` file contains only configuration metadata (resource names), not sensitive credentials.

### State File Isolation

Each environment maintains a separate state file to prevent cross-contamination:
- Dev: `dev.terraform.tfstate`
- Test: `test.terraform.tfstate`
- Prod: `prod.terraform.tfstate`
- Feature: `<username>.terraform.tfstate`

## Resource Naming Convention

Resources follow the pattern: `<project>-<environment>-<resource-type>`

Examples:
- Resource Group: `iemlops-dev-rg`
- ML Workspace: `iemlops-dev-mlw`
- Storage Account: `iemlopsdevab12c3sa` (with random suffix for global uniqueness)

## Project Structure

```
.
├── infrastructure/
│   └── terraform/
│       ├── main.tf              # Root configuration
│       ├── variables.tf         # Variable definitions
│       ├── outputs.tf           # Output definitions
│       ├── backend.tf           # Backend configuration
│       ├── modules/
│       │   ├── ml-workspace/    # Azure ML Workspace module
│       │   ├── storage/         # Storage Account module
│       │   ├── compute/         # Compute module (placeholder)
│       │   └── networking/      # Networking module (placeholder)
│       └── environments/
│           ├── dev.auto.tfvars
│           ├── test.auto.tfvars
│           ├── prod.auto.tfvars
│           └── feature.auto.tfvars.template
├── src/                         # Application code (future)
├── .github/workflows/           # CI/CD workflows (future)
├── docs/                        # Documentation
└── tests/                       # Tests
```

## Quality Gates

### Makefile Commands

All infrastructure operations are available through simple make commands:

#### Setup Commands
```bash
make setup              # Install all required development tools
make bootstrap          # Create Azure backend storage
make quickstart ENV=dev # Complete setup (setup + bootstrap + init)
```

#### Environment Initialization
```bash
make init-dev           # Initialize dev environment
make init-test          # Initialize test environment
make init-prod          # Initialize prod environment
```

#### Terraform Operations
```bash
make plan ENV=dev       # Plan infrastructure changes
make apply ENV=dev      # Apply infrastructure changes
make destroy ENV=dev    # Destroy infrastructure (with confirmation)
```

#### Code Quality
```bash
make validate           # Validate Terraform configuration
make fmt                # Format Terraform files
make lint               # Run TFLint
```

#### Utilities
```bash
make clean              # Remove local Terraform state and cache
make help               # Display all available commands
```

### Common Workflows

#### New Developer Onboarding
```bash
az login
make quickstart ENV=dev
```

#### Daily Development
```bash
make plan ENV=dev       # Review changes
make apply ENV=dev      # Apply changes
```

#### Environment Switching
```bash
make init-test          # Switch to test
make plan ENV=test      # Plan for test
make apply ENV=test     # Apply to test
```

### Local Validation

Pre-commit hooks automatically run on git commit:
- `terraform fmt` - Format Terraform code
- `terraform validate` - Validate syntax
- `tflint` - Lint and security scan
- `detect-private-key` - Prevent secret commits

### Manual Validation (Alternative)

If you prefer to run commands directly:

```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Run TFLint
cd infrastructure/terraform && tflint
```

## License

[Your License]
