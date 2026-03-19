## Why

Developers face a confusing onboarding experience with the Azure MLOps infrastructure due to manual tool installation, unclear backend storage setup, and complex Terraform initialization steps. This automation eliminates the chicken-and-egg problem of backend state management and reduces onboarding time from 30 minutes to 5 minutes with clear, guided workflows.

## What Changes

- Create Makefile with developer-friendly commands (setup, bootstrap, init, plan, apply, destroy)
- Add bash scripts for tool installation (terraform, tflint, azure-cli, azure-functions-core-tools)
- Add bash script for automated Azure backend storage creation (resource group, storage account, container)
- Add bash script for environment initialization with automatic .auto.tfvars selection
- Add bash script wrapper for terraform commands with environment validation
- Update README.md with revised prerequisites (Xcode CLT and Homebrew as manual prerequisites)
- Update README.md with new automated workflow documentation
- Add .env.local to .gitignore for local storage of backend access keys
- Add quickstart command for one-step developer onboarding
- Add validation, formatting, and linting commands to Makefile

## Capabilities

### New Capabilities
- `makefile-interface`: Developer-friendly command interface with help, validation, and error handling
- `tool-installation`: Automated installation of required tools via Homebrew with version checking
- `backend-bootstrap`: Automated Azure backend storage creation with idempotent operations
- `environment-initialization`: Automated Terraform initialization with environment-specific configuration
- `terraform-operations`: Wrapper commands for plan, apply, destroy with safety checks

### Modified Capabilities
<!-- No existing capabilities are being modified -->

## Impact

- New files: Makefile, scripts/setup-tools.sh, scripts/bootstrap-backend.sh, scripts/init-env.sh, scripts/terraform-cmd.sh
- Modified files: README.md (prerequisites and workflow sections), .gitignore (add .env.local)
- Developer workflow changes: Manual multi-step process replaced with make commands
- Requires Xcode Command Line Tools and Homebrew as documented prerequisites
- Backend storage access key stored locally in .env.local (gitignored)
- Reduces cognitive load for new developers joining the project
- Enables consistent environment setup across team members
