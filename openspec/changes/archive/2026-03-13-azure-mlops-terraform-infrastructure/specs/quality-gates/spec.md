## ADDED Requirements

### Requirement: TFLint configuration
The system SHALL provide .tflint.hcl configuration file in infrastructure/terraform/ with Azure ruleset and security rules enabled.

#### Scenario: Enable Azure ruleset
- **WHEN** .tflint.hcl is present in infrastructure/terraform/
- **THEN** configuration includes azurerm plugin version 0.25.0 or later

#### Scenario: Enable Terraform recommended preset
- **WHEN** TFLint runs with the configuration
- **THEN** terraform plugin with recommended preset is active

#### Scenario: Enforce required providers rule
- **WHEN** TFLint scans Terraform code
- **THEN** terraform_required_providers rule validates provider declarations

#### Scenario: Enforce required version rule
- **WHEN** TFLint scans Terraform code
- **THEN** terraform_required_version rule validates Terraform version constraint

#### Scenario: Enforce naming convention rule
- **WHEN** TFLint scans Terraform code
- **THEN** terraform_naming_convention rule validates resource naming patterns

#### Scenario: Detect sensitive variable defaults
- **WHEN** TFLint scans variables with sensitive=true
- **THEN** terraform_sensitive_variable_no_default rule fails if default values are present

#### Scenario: Enforce resource tagging
- **WHEN** TFLint scans Azure resources
- **THEN** azurerm_resource_missing_tags rule validates Environment, ManagedBy, and Project tags are present

### Requirement: Secret detection
The system SHALL detect hardcoded secrets and sensitive values in Terraform code using TFLint rules.

#### Scenario: Detect hardcoded secret in variable default
- **WHEN** variable has default value containing secret pattern
- **THEN** TFLint fails with terraform_sensitive_variable_no_default error

#### Scenario: Detect hardcoded password in resource
- **WHEN** resource attribute contains hardcoded password or key
- **THEN** TFLint detects and reports the security violation

### Requirement: Pre-commit framework configuration
The system SHALL provide .pre-commit-config.yaml at repository root with Terraform and security hooks.

#### Scenario: Configure Terraform formatting hook
- **WHEN** .pre-commit-config.yaml exists
- **THEN** configuration includes terraform_fmt hook with recursive argument

#### Scenario: Configure Terraform validation hook
- **WHEN** .pre-commit-config.yaml exists
- **THEN** configuration includes terraform_validate hook with retry-once-with-cleanup

#### Scenario: Configure TFLint hook
- **WHEN** .pre-commit-config.yaml exists
- **THEN** configuration includes terraform_tflint hook pointing to .tflint.hcl config

#### Scenario: Configure documentation generation hook
- **WHEN** .pre-commit-config.yaml exists
- **THEN** configuration includes terraform_docs hook to auto-generate README.md

#### Scenario: Configure private key detection
- **WHEN** .pre-commit-config.yaml exists
- **THEN** configuration includes detect-private-key hook from pre-commit-hooks

#### Scenario: Configure merge conflict detection
- **WHEN** .pre-commit-config.yaml exists
- **THEN** configuration includes check-merge-conflict hook

#### Scenario: Configure whitespace cleanup
- **WHEN** .pre-commit-config.yaml exists
- **THEN** configuration includes trailing-whitespace and end-of-file-fixer hooks

### Requirement: Python environment with uv
The system SHALL use uv package manager with virtual environment for Python tooling dependencies.

#### Scenario: Create virtual environment
- **WHEN** developer runs uv venv
- **THEN** .venv directory is created with Python virtual environment

#### Scenario: Install pre-commit with uv
- **WHEN** developer runs uv pip install pre-commit in activated venv
- **THEN** pre-commit is installed in the virtual environment

#### Scenario: Activate virtual environment on macOS
- **WHEN** developer runs source .venv/bin/activate
- **THEN** virtual environment is activated and uv pip commands use venv

### Requirement: Python project configuration
The system SHALL provide pyproject.toml with project metadata and pre-commit dependency.

#### Scenario: Define project metadata
- **WHEN** pyproject.toml exists at repository root
- **THEN** file contains project name, version, and requires-python >= 3.10

#### Scenario: Declare pre-commit dependency
- **WHEN** pyproject.toml exists
- **THEN** dependencies include pre-commit >= 3.5.0

#### Scenario: Declare dev dependencies
- **WHEN** pyproject.toml exists
- **THEN** tool.uv.dev-dependencies includes pre-commit

### Requirement: Python version specification
The system SHALL provide .python-version file specifying Python 3.11 or later.

#### Scenario: Specify Python version
- **WHEN** .python-version exists at repository root
- **THEN** file contains "3.11" or later version

### Requirement: Pre-commit installation
The system SHALL enable pre-commit hooks installation via pre-commit install command.

#### Scenario: Install git hooks
- **WHEN** developer runs pre-commit install after setup
- **THEN** git commit triggers pre-commit hooks automatically

#### Scenario: Test hooks on all files
- **WHEN** developer runs pre-commit run --all-files
- **THEN** all configured hooks execute against entire repository

### Requirement: Local TFLint execution
The system SHALL support manual TFLint execution for local validation.

#### Scenario: Initialize TFLint
- **WHEN** developer runs tflint --init in infrastructure/terraform/
- **THEN** TFLint downloads required plugins including azurerm ruleset

#### Scenario: Run TFLint manually
- **WHEN** developer runs tflint in infrastructure/terraform/
- **THEN** TFLint scans Terraform files and reports issues

### Requirement: Git commit validation
The system SHALL run pre-commit hooks automatically on git commit to validate code quality.

#### Scenario: Format Terraform on commit
- **WHEN** developer commits Terraform files
- **THEN** terraform_fmt hook automatically formats code before commit

#### Scenario: Validate Terraform on commit
- **WHEN** developer commits Terraform files
- **THEN** terraform_validate hook checks syntax and configuration

#### Scenario: Run TFLint on commit
- **WHEN** developer commits Terraform files
- **THEN** terraform_tflint hook scans for issues and secrets

#### Scenario: Block commit on critical issues
- **WHEN** pre-commit hooks detect critical errors or secrets
- **THEN** git commit fails and displays error messages

### Requirement: GitHub Actions preparation
The system SHALL prepare for future GitHub Actions integration with TFLint in PR workflow.

#### Scenario: Document GitHub Actions workflow location
- **WHEN** .github/workflows/ directory structure is defined
- **THEN** terraform-lint.yml workflow location is documented for future implementation

#### Scenario: Define PR path filters
- **WHEN** GitHub Actions workflow is implemented
- **THEN** workflow triggers only on changes to infrastructure/terraform/** paths
