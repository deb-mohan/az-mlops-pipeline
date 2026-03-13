## Why

Build foundational Terraform infrastructure for an Azure MLOps pipeline supporting multiple environments (dev, test, prod) and dynamic feature branches. This establishes the infrastructure layer before implementing GitHub Actions automation and ML pipeline workflows. The DRY, modular approach prevents code duplication and enables rapid environment provisioning for development teams.

## What Changes

- Create Terraform infrastructure using monorepo Pattern 1 (flat separation of infrastructure and application code)
- Implement DRY multi-environment configuration with single source of truth (main.tf) and environment-specific .auto.tfvars files
- Build reusable Terraform modules for Azure ML Workspace, Storage, Compute, and Networking
- Establish resource naming convention: `<project>-<environment>-<resource-type>` with random suffix for globally unique resources
- Configure Azure Storage backend with partial configuration for dynamic state management per environment
- Integrate TFLint with Azure ruleset for security scanning and secret detection
- Set up pre-commit hooks using uv/venv for local validation (terraform fmt, validate, tflint, secret detection)
- Create Python project structure (pyproject.toml, .python-version) for tooling dependencies
- Support static environments (dev, test, prod) and dynamic feature branch environments (username-based)

## Capabilities

### New Capabilities
- `terraform-infrastructure`: Core Terraform configuration with DRY multi-environment support, modular architecture, and Azure ML resources
- `quality-gates`: TFLint configuration, pre-commit hooks, and local validation setup for security and code quality
- `project-structure`: Monorepo layout with infrastructure, src, docs, tests, and configuration files

### Modified Capabilities
<!-- No existing capabilities are being modified -->

## Impact

- New directory structure at repository root: `infrastructure/terraform/`, `src/`, `.github/`, `docs/`, `tests/`
- New configuration files: `.tflint.hcl`, `.pre-commit-config.yaml`, `pyproject.toml`, `.python-version`, `.gitignore`
- Terraform state will be stored in Azure Storage (backend configuration required)
- Developers will need uv, Terraform >= 1.5, and TFLint installed locally
- GitHub repository and feature branch setup deferred to user
- GitHub Actions workflows and MLOps pipeline implementation are out of scope for this phase
