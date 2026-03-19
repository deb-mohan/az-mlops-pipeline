## ADDED Requirements

### Requirement: Environment parameter validation
The system SHALL validate environment parameter before initialization.

#### Scenario: Valid environment provided
- **WHEN** init script receives ENV=dev parameter
- **THEN** system validates parameter and proceeds with initialization

#### Scenario: Missing environment parameter
- **WHEN** init script is called without ENV parameter
- **THEN** system displays error message with usage example and exits

#### Scenario: Invalid environment value
- **WHEN** init script receives invalid ENV value
- **THEN** system displays error message listing valid options (dev, test, prod) and exits

### Requirement: Environment variable file verification
The system SHALL verify corresponding .auto.tfvars file exists for environment.

#### Scenario: Environment file exists
- **WHEN** init script checks for environments/dev.auto.tfvars
- **THEN** system displays confirmation and proceeds

#### Scenario: Environment file missing
- **WHEN** init script checks for environments file and it does not exist
- **THEN** system displays error message with file path and exits

### Requirement: Copy environment configuration
The system SHALL copy environment-specific .auto.tfvars to terraform directory.

#### Scenario: Copy configuration file
- **WHEN** init script runs for dev environment
- **THEN** system copies environments/dev.auto.tfvars to infrastructure/terraform/dev.auto.tfvars

#### Scenario: Overwrite existing configuration
- **WHEN** .auto.tfvars file already exists in terraform directory
- **THEN** system overwrites with latest from environments directory

### Requirement: Terraform initialization with backend configuration
The system SHALL initialize Terraform with environment-specific backend key.

#### Scenario: Initialize with backend key
- **WHEN** init script runs for dev environment
- **THEN** system runs terraform init -backend-config="key=dev.terraform.tfstate"

#### Scenario: Reconfigure backend
- **WHEN** switching from one environment to another
- **THEN** system runs terraform init with -reconfigure flag

### Requirement: Backend state file isolation
The system SHALL ensure each environment uses separate state file.

#### Scenario: Dev environment state
- **WHEN** initializing dev environment
- **THEN** system configures backend with key=dev.terraform.tfstate

#### Scenario: Test environment state
- **WHEN** initializing test environment
- **THEN** system configures backend with key=test.terraform.tfstate

#### Scenario: Prod environment state
- **WHEN** initializing prod environment
- **THEN** system configures backend with key=prod.terraform.tfstate

### Requirement: Initialization success verification
The system SHALL verify Terraform initialization completed successfully.

#### Scenario: Successful initialization
- **WHEN** terraform init completes without errors
- **THEN** system displays success message with next steps (plan, apply)

#### Scenario: Initialization failure
- **WHEN** terraform init encounters error
- **THEN** system displays error message and exits with non-zero status

### Requirement: Working directory validation
The system SHALL verify script is run from correct directory.

#### Scenario: Run from project root
- **WHEN** init script is called from project root
- **THEN** system changes to infrastructure/terraform directory and proceeds

#### Scenario: Run from terraform directory
- **WHEN** init script is called from infrastructure/terraform
- **THEN** system proceeds with initialization
