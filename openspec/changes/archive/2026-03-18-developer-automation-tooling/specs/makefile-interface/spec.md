## ADDED Requirements

### Requirement: Help command displays available targets
The system SHALL provide a help command that displays all available Makefile targets with descriptions.

#### Scenario: Display help
- **WHEN** developer runs make help or make without arguments
- **THEN** system displays formatted list of all available commands with descriptions

### Requirement: Tool prerequisite checking
The system SHALL verify required tools are installed before executing commands that depend on them.

#### Scenario: Tools installed
- **WHEN** developer runs make command that requires tools
- **THEN** system checks for terraform, tflint, az, and func, and proceeds if all present

#### Scenario: Tools missing
- **WHEN** developer runs make command and required tools are missing
- **THEN** system displays error message indicating which tools are missing and suggests running make setup

### Requirement: Environment parameter validation
The system SHALL validate environment parameters for commands that require them.

#### Scenario: Valid environment provided
- **WHEN** developer runs make plan ENV=dev
- **THEN** system validates ENV parameter and executes command

#### Scenario: Missing environment parameter
- **WHEN** developer runs make plan without ENV parameter
- **THEN** system displays error message with usage example

#### Scenario: Invalid environment value
- **WHEN** developer provides invalid ENV value
- **THEN** system displays error message listing valid environment options

### Requirement: Destructive operation confirmation
The system SHALL require user confirmation before executing destructive operations.

#### Scenario: Destroy command confirmation
- **WHEN** developer runs make destroy ENV=dev
- **THEN** system displays warning message and waits for ENTER key before proceeding

#### Scenario: Destroy command cancellation
- **WHEN** developer runs make destroy and presses Ctrl+C at confirmation prompt
- **THEN** system cancels operation without destroying resources

### Requirement: Quickstart command for onboarding
The system SHALL provide a quickstart command that runs complete setup in sequence.

#### Scenario: Quickstart execution
- **WHEN** developer runs make quickstart ENV=dev
- **THEN** system executes setup, bootstrap, and init-dev in sequence

#### Scenario: Quickstart failure handling
- **WHEN** quickstart encounters error in any step
- **THEN** system stops execution and displays error message indicating which step failed

### Requirement: Code quality commands
The system SHALL provide commands for validation, formatting, and linting.

#### Scenario: Validate Terraform configuration
- **WHEN** developer runs make validate
- **THEN** system runs terraform validate and reports results

#### Scenario: Format Terraform files
- **WHEN** developer runs make fmt
- **THEN** system runs terraform fmt -recursive and formats all files

#### Scenario: Lint Terraform files
- **WHEN** developer runs make lint
- **THEN** system runs tflint and reports issues

### Requirement: Clean command for local files
The system SHALL provide a clean command to remove local Terraform state and cache files.

#### Scenario: Clean local files
- **WHEN** developer runs make clean
- **THEN** system removes .terraform directories, .tfstate files, and .terraform.lock.hcl files
