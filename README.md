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

- [uv](https://docs.astral.sh/uv/) - Modern Python package manager
- [Terraform](https://www.terraform.io/downloads) >= 1.5
- [TFLint](https://github.com/terraform-linters/tflint) - Terraform linter

## Developer Setup

### 1. Clone the repository

```bash
git clone <repo-url>
cd azure-mlops-project
```

### 2. Create and activate Python virtual environment

```bash
uv venv
source .venv/bin/activate  # macOS/Linux
# or
.venv\Scripts\activate     # Windows
```

### 3. Install dependencies

```bash
uv pip install -e .
```

### 4. Install pre-commit hooks

```bash
pre-commit install
```

### 5. Initialize TFLint

```bash
cd infrastructure/terraform
tflint --init
```

### 6. Test setup

```bash
pre-commit run --all-files
```

## Usage

### Deploy to Dev Environment

```bash
cd infrastructure/terraform

# Copy dev configuration
cp environments/dev.auto.tfvars .

# Initialize Terraform with dev state
terraform init -backend-config="key=dev.terraform.tfstate"

# Plan and apply
terraform plan
terraform apply
```

### Deploy to Test Environment

```bash
cd infrastructure/terraform

# Copy test configuration
cp environments/test.auto.tfvars .

# Initialize Terraform with test state
terraform init -backend-config="key=test.terraform.tfstate" -reconfigure

# Plan and apply
terraform plan
terraform apply
```

### Deploy to Prod Environment

```bash
cd infrastructure/terraform

# Copy prod configuration
cp environments/prod.auto.tfvars .

# Initialize Terraform with prod state
terraform init -backend-config="key=prod.terraform.tfstate" -reconfigure

# Plan and apply
terraform plan
terraform apply
```

## Feature Branch Environments

For feature branch or PR preview environments:

1. Copy the template:
```bash
cd infrastructure/terraform/environments
cp feature.auto.tfvars.template johndoe.auto.tfvars
```

2. Edit `johndoe.auto.tfvars` and replace `<username>` with your username

3. Deploy:
```bash
cd infrastructure/terraform
cp environments/johndoe.auto.tfvars .
terraform init -backend-config="key=johndoe.terraform.tfstate"
terraform plan
terraform apply
```

## Backend Configuration and State Management

This project uses Azure Storage for Terraform state management with partial backend configuration:

- **Resource Group**: `terraform-state-rg`
- **Storage Account**: `tfstateiemlops`
- **Container**: `tfstate`
- **State File**: `<environment>.terraform.tfstate` (provided at init time)

Each environment maintains a separate state file to prevent cross-contamination:
- Dev: `dev.terraform.tfstate`
- Test: `test.terraform.tfstate`
- Prod: `prod.terraform.tfstate`
- Feature: `<username>.terraform.tfstate`

The backend must be configured before first use. Ensure the storage account and container exist in Azure.

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

### Local Validation

Pre-commit hooks automatically run on git commit:
- `terraform fmt` - Format Terraform code
- `terraform validate` - Validate syntax
- `tflint` - Lint and security scan
- `detect-private-key` - Prevent secret commits

### Manual Validation

```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Run TFLint
tflint
```

## License

[Your License]
