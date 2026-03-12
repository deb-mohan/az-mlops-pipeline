## ADDED Requirements

### Requirement: Environment parameter validation for operations
The system SHALL validate environment parameter for all terraform operations.

#### Scenario: Valid environment for plan
- **WHEN** developer runs terraform plan wrapper with ENV=dev
- **THEN** system validates parameter and executes terraform plan

#### Scenario: Missing environment for apply
- **WHEN** developer runs terraform apply wrapper without ENV parameter
- **THEN** system displays error message and exits

### Requirement: Terraform initialization check
The system SHALL verify Terraform is initialized before running operations.

#### Scenario: Terraform initialized
- **WHEN** .terraform directory exists
- **THEN** system proceeds with terraform operation

#### Scenario: Terraform not initialized
- **WHEN** .terraform directory does not exist
- **THEN** system displays error message suggesting to run init first and exits

### Requirement: Environment configuration verification
The system SHALL verify correct .auto.tfvars file is present for environment.

#### Scenario: Correct configuration present
- **WHEN** running plan for dev and dev.auto.tfvars exists
- **THEN** system proceeds with operation

#### Scenario: Configuration mismatch
- **WHEN** running plan for dev but dev.auto.tfvars is missing
- **THEN** system displays error message suggesting to run init first and exits

### Requirement: Terraform plan operation
The system SHALL execute terraform plan with environment context.

#### Scenario: Run plan for dev
- **WHEN** developer runs plan wrapper with ENV=dev
- **THEN** system executes terraform plan and displays output

#### Scenario: Plan with output file
- **WHEN** developer runs plan wrapper with output flag
- **THEN** system saves plan to file for later apply

### Requirement: Terraform apply operation
The system SHALL execute terraform apply with environment context.

#### Scenario: Run apply for dev
- **WHEN** developer runs apply wrapper with ENV=dev
- **THEN** system executes terraform apply and displays output

#### Scenario: Apply with auto-approve
- **WHEN** developer runs apply wrapper with auto-approve flag
- **THEN** system executes terraform apply without confirmation prompt

### Requirement: Terraform destroy operation with confirmation
The system SHALL require explicit confirmation before destroying resources.

#### Scenario: Destroy with confirmation
- **WHEN** developer runs destroy wrapper with ENV=dev
- **THEN** system displays warning, waits for ENTER key, then executes terraform destroy

#### Scenario: Destroy cancellation
- **WHEN** developer presses Ctrl+C at destroy confirmation
- **THEN** system cancels operation without destroying resources

### Requirement: Terraform validate operation
The system SHALL execute terraform validate without environment parameter.

#### Scenario: Run validate
- **WHEN** developer runs validate wrapper
- **THEN** system executes terraform validate and displays results

### Requirement: Terraform format operation
The system SHALL execute terraform fmt recursively.

#### Scenario: Run format
- **WHEN** developer runs format wrapper
- **THEN** system executes terraform fmt -recursive and formats all files

### Requirement: Pass-through of terraform flags
The system SHALL pass additional flags to underlying terraform commands.

#### Scenario: Plan with target flag
- **WHEN** developer runs plan wrapper with -target=resource flag
- **THEN** system passes flag to terraform plan command

#### Scenario: Apply with var flag
- **WHEN** developer runs apply wrapper with -var flag
- **THEN** system passes flag to terraform apply command

### Requirement: Working directory management
The system SHALL ensure operations run in correct terraform directory.

#### Scenario: Run from project root
- **WHEN** wrapper script is called from project root
- **THEN** system changes to infrastructure/terraform directory before executing terraform

#### Scenario: Run from terraform directory
- **WHEN** wrapper script is called from infrastructure/terraform
- **THEN** system executes terraform in current directory
