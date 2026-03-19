## ADDED Requirements

### Requirement: Azure CLI authentication verification
The system SHALL verify Azure CLI is authenticated before attempting backend operations.

#### Scenario: User authenticated
- **WHEN** bootstrap script runs and user is logged in to Azure CLI
- **THEN** system displays current account and proceeds with backend creation

#### Scenario: User not authenticated
- **WHEN** bootstrap script runs and user is not logged in
- **THEN** system displays error message with login instructions and exits

### Requirement: Backend resource group creation
The system SHALL create backend resource group if it does not exist.

#### Scenario: Resource group exists
- **WHEN** bootstrap script checks for terraform-state-rg
- **THEN** system displays confirmation and skips creation

#### Scenario: Resource group does not exist
- **WHEN** bootstrap script checks for terraform-state-rg and it is missing
- **THEN** system creates resource group in specified location and displays confirmation

### Requirement: Backend storage account creation
The system SHALL create backend storage account if it does not exist.

#### Scenario: Storage account exists
- **WHEN** bootstrap script checks for tfstateiemlops
- **THEN** system displays confirmation and skips creation

#### Scenario: Storage account does not exist
- **WHEN** bootstrap script checks for tfstateiemlops and it is missing
- **THEN** system creates storage account with Standard_LRS SKU and displays confirmation

### Requirement: Backend container creation
The system SHALL create backend container if it does not exist.

#### Scenario: Container exists
- **WHEN** bootstrap script checks for tfstate container
- **THEN** system displays confirmation and skips creation

#### Scenario: Container does not exist
- **WHEN** bootstrap script checks for tfstate container and it is missing
- **THEN** system creates container and displays confirmation

### Requirement: Storage account access key retrieval
The system SHALL retrieve storage account access key and save to .env.local.

#### Scenario: Retrieve access key
- **WHEN** backend resources are created or verified
- **THEN** system retrieves primary access key and saves to .env.local file

#### Scenario: .env.local file creation
- **WHEN** .env.local does not exist
- **THEN** system creates file with access key and displays confirmation

#### Scenario: .env.local file update
- **WHEN** .env.local exists
- **THEN** system updates STORAGE_ACCOUNT_KEY value and displays confirmation

### Requirement: Idempotent operations
The system SHALL support running bootstrap multiple times without errors.

#### Scenario: Run bootstrap twice
- **WHEN** developer runs bootstrap script after resources already exist
- **THEN** system verifies all resources exist and completes successfully without errors

### Requirement: Bootstrap completion summary
The system SHALL display summary of backend configuration.

#### Scenario: Display completion message
- **WHEN** bootstrap completes successfully
- **THEN** system displays resource group name, storage account name, container name, and next steps
