## ADDED Requirements

### Requirement: Monorepo directory structure
The system SHALL organize code using Pattern 1 flat separation with top-level directories for infrastructure, src, .github, docs, and tests.

#### Scenario: Create infrastructure directory
- **WHEN** repository is initialized
- **THEN** infrastructure/terraform/ directory exists containing all Terraform code

#### Scenario: Create source code directory
- **WHEN** repository is initialized
- **THEN** src/ directory exists with subdirectories for functions/, ml/, and shared/

#### Scenario: Create GitHub workflows directory
- **WHEN** repository is initialized
- **THEN** .github/workflows/ directory exists for future CI/CD workflows

#### Scenario: Create documentation directory
- **WHEN** repository is initialized
- **THEN** docs/ directory exists for project documentation

#### Scenario: Create tests directory
- **WHEN** repository is initialized
- **THEN** tests/ directory exists for infrastructure and unit tests

### Requirement: Terraform directory structure
The system SHALL organize Terraform code with modules/ and environments/ subdirectories under infrastructure/terraform/.

#### Scenario: Create modules directory
- **WHEN** infrastructure/terraform/ is initialized
- **THEN** modules/ directory contains subdirectories for ml-workspace/, storage/, compute/, and networking/

#### Scenario: Create environments directory
- **WHEN** infrastructure/terraform/ is initialized
- **THEN** environments/ directory contains dev.auto.tfvars, test.auto.tfvars, prod.auto.tfvars, and feature.auto.tfvars.template

#### Scenario: Place root Terraform files
- **WHEN** infrastructure/terraform/ is initialized
- **THEN** main.tf, variables.tf, outputs.tf, and backend.tf exist at root level

### Requirement: Module structure
The system SHALL organize each Terraform module with main.tf, variables.tf, and outputs.tf files.

#### Scenario: Create ml-workspace module structure
- **WHEN** modules/ml-workspace/ is created
- **THEN** directory contains main.tf, variables.tf, and outputs.tf

#### Scenario: Create storage module structure
- **WHEN** modules/storage/ is created
- **THEN** directory contains main.tf, variables.tf, and outputs.tf

#### Scenario: Create compute module structure
- **WHEN** modules/compute/ is created
- **THEN** directory contains main.tf, variables.tf, and outputs.tf

#### Scenario: Create networking module structure
- **WHEN** modules/networking/ is created
- **THEN** directory contains main.tf, variables.tf, and outputs.tf

### Requirement: Configuration files at repository root
The system SHALL place configuration files (.tflint.hcl, .pre-commit-config.yaml, pyproject.toml, .python-version, .gitignore) at repository root.

#### Scenario: Place TFLint configuration
- **WHEN** repository is initialized
- **THEN** infrastructure/terraform/.tflint.hcl exists with Azure ruleset configuration

#### Scenario: Place pre-commit configuration
- **WHEN** repository is initialized
- **THEN** .pre-commit-config.yaml exists at repository root

#### Scenario: Place Python project configuration
- **WHEN** repository is initialized
- **THEN** pyproject.toml exists at repository root with project metadata

#### Scenario: Place Python version file
- **WHEN** repository is initialized
- **THEN** .python-version exists at repository root specifying Python 3.11

#### Scenario: Place gitignore file
- **WHEN** repository is initialized
- **THEN** .gitignore exists at repository root with Python, Terraform, IDE, and OS exclusions

### Requirement: Gitignore configuration
The system SHALL exclude .venv/, .terraform/, *.tfstate, IDE files, and OS files from version control.

#### Scenario: Ignore Python virtual environment
- **WHEN** .gitignore is present
- **THEN** .venv/ and __pycache__/ patterns are excluded

#### Scenario: Ignore Terraform state files
- **WHEN** .gitignore is present
- **THEN** *.tfstate, *.tfstate.*, and .terraform/ patterns are excluded

#### Scenario: Ignore IDE files
- **WHEN** .gitignore is present
- **THEN** .vscode/, .idea/, *.swp, and *.swo patterns are excluded

#### Scenario: Ignore OS files
- **WHEN** .gitignore is present
- **THEN** .DS_Store and Thumbs.db patterns are excluded

#### Scenario: Commit auto.tfvars files
- **WHEN** .gitignore is present
- **THEN** *.auto.tfvars pattern is NOT excluded (these files should be committed)

#### Scenario: Ignore local override files
- **WHEN** .gitignore is present
- **THEN** *.local.tfvars and secrets.tfvars patterns are excluded

### Requirement: README documentation
The system SHALL provide README.md at repository root with project overview and developer setup instructions.

#### Scenario: Document prerequisites
- **WHEN** README.md exists
- **THEN** prerequisites section lists uv, Terraform >= 1.5, and TFLint

#### Scenario: Document setup steps
- **WHEN** README.md exists
- **THEN** setup section includes commands for uv venv, dependency installation, and pre-commit setup

#### Scenario: Document TFLint initialization
- **WHEN** README.md exists
- **THEN** setup section includes tflint --init command

#### Scenario: Document testing setup
- **WHEN** README.md exists
- **THEN** setup section includes pre-commit run --all-files command

### Requirement: Source code placeholder structure
The system SHALL create placeholder directories for future application code in src/.

#### Scenario: Create functions directory
- **WHEN** src/ is initialized
- **THEN** functions/ subdirectory exists for future Azure Functions code

#### Scenario: Create ML directory
- **WHEN** src/ is initialized
- **THEN** ml/ subdirectory exists for future ML pipeline code

#### Scenario: Create shared directory
- **WHEN** src/ is initialized
- **THEN** shared/ subdirectory exists for common utilities

### Requirement: Tests directory structure
The system SHALL organize tests with subdirectories for infrastructure and unit tests.

#### Scenario: Create infrastructure tests directory
- **WHEN** tests/ is initialized
- **THEN** infrastructure/ subdirectory exists for Terraform tests

#### Scenario: Create unit tests directory
- **WHEN** tests/ is initialized
- **THEN** unit/ subdirectory exists for code unit tests

### Requirement: Documentation directory
The system SHALL provide docs/ directory for project documentation.

#### Scenario: Create docs directory
- **WHEN** repository is initialized
- **THEN** docs/ directory exists at repository root
