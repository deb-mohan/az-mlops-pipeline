## ADDED Requirements

### Requirement: DRY multi-environment configuration
The system SHALL use a single main.tf file as the source of truth for all environments with environment-specific values provided through .auto.tfvars files.

#### Scenario: Deploy to dev environment
- **WHEN** developer runs terraform plan in infrastructure/terraform with dev.auto.tfvars present
- **THEN** Terraform automatically loads dev.auto.tfvars and generates plan for dev environment resources

#### Scenario: Deploy to prod environment
- **WHEN** developer runs terraform plan in infrastructure/terraform with prod.auto.tfvars present
- **THEN** Terraform automatically loads prod.auto.tfvars and generates plan for prod environment resources with production-appropriate sizing

#### Scenario: Deploy feature branch environment
- **WHEN** developer creates username.auto.tfvars with environment variable set to their username
- **THEN** Terraform creates isolated environment with username-prefixed resources

### Requirement: Resource naming convention
The system SHALL name Azure resources using the pattern `<project>-<environment>-<resource-type>` for standard resources and SHALL append random suffix for globally unique resources like storage accounts.

#### Scenario: Create resource group
- **WHEN** Terraform creates a resource group for dev environment with project name "iemlops"
- **THEN** resource group is named "iemlops-dev-rg"

#### Scenario: Create storage account with unique name
- **WHEN** Terraform creates a storage account for dev environment
- **THEN** storage account name includes random suffix (e.g., "iemlopsdevab12c3sa") to ensure global uniqueness

#### Scenario: Create ML workspace
- **WHEN** Terraform creates ML workspace for test environment
- **THEN** workspace is named "iemlops-test-mlw"

### Requirement: Modular Terraform architecture
The system SHALL organize Terraform code into reusable modules for ml-workspace, storage, compute, and networking components.

#### Scenario: Use ML workspace module
- **WHEN** main.tf calls the ml-workspace module with required parameters
- **THEN** module creates Azure ML Workspace with all dependencies configured

#### Scenario: Use storage module
- **WHEN** main.tf calls the storage module with resource group and location
- **THEN** module creates storage account with random suffix for uniqueness

#### Scenario: Reuse modules across environments
- **WHEN** multiple environments reference the same module
- **THEN** each environment gets identical resource configuration with only variable values differing

### Requirement: Azure Storage backend configuration
The system SHALL use Azure Storage backend with partial configuration to support dynamic state file naming per environment.

#### Scenario: Initialize dev environment state
- **WHEN** developer runs terraform init with backend-config key=dev.terraform.tfstate
- **THEN** Terraform initializes backend pointing to dev.terraform.tfstate in Azure Storage

#### Scenario: Initialize feature branch state
- **WHEN** developer runs terraform init with backend-config key=username.terraform.tfstate
- **THEN** Terraform creates isolated state file for feature branch environment

#### Scenario: Prevent state file conflicts
- **WHEN** multiple developers work on different environments simultaneously
- **THEN** each environment maintains separate state file with no cross-contamination

### Requirement: Random provider for unique naming
The system SHALL use Terraform random provider to generate consistent suffixes for globally unique resource names.

#### Scenario: Generate storage account suffix
- **WHEN** Terraform creates random_string resource with environment keeper
- **THEN** random suffix is generated and remains consistent across applies for that environment

#### Scenario: Regenerate suffix on environment change
- **WHEN** environment variable changes in keeper configuration
- **THEN** new random suffix is generated for the new environment

### Requirement: Required Terraform providers
The system SHALL declare azurerm provider version ~> 3.0 and random provider version ~> 3.5 as required providers.

#### Scenario: Initialize Terraform with providers
- **WHEN** developer runs terraform init
- **THEN** Terraform downloads azurerm and random providers with specified version constraints

### Requirement: Environment-specific variable files
The system SHALL provide separate .auto.tfvars files for dev, test, and prod environments in the environments/ directory.

#### Scenario: Load dev configuration
- **WHEN** dev.auto.tfvars exists in infrastructure/terraform/environments/
- **THEN** file contains dev-specific values for project_name, environment, location, ml_workspace_sku, and tags

#### Scenario: Load prod configuration with different sizing
- **WHEN** prod.auto.tfvars exists in infrastructure/terraform/environments/
- **THEN** file contains prod-specific values including Enterprise SKU for ML workspace

#### Scenario: Template for feature branches
- **WHEN** feature.auto.tfvars.template exists in environments/
- **THEN** developers can copy and customize it for their feature branch deployments

### Requirement: Variable definitions
The system SHALL define variables for project_name, environment, location, ml_workspace_sku, and tags in variables.tf.

#### Scenario: Validate required variables
- **WHEN** Terraform plan runs without required variables
- **THEN** Terraform prompts for missing variable values or fails validation

#### Scenario: Use default values
- **WHEN** optional variables like ml_workspace_sku are not provided
- **THEN** Terraform uses default value of "Basic"

### Requirement: Common resource tagging
The system SHALL apply common tags to all resources including Environment, ManagedBy, and Project using locals.

#### Scenario: Tag resources automatically
- **WHEN** any Azure resource is created
- **THEN** resource includes Environment, ManagedBy=terraform, and Project tags merged with custom tags

### Requirement: Azure ML Workspace module
The system SHALL provide ml-workspace module that creates Azure ML Workspace with configurable SKU.

#### Scenario: Create Basic ML workspace
- **WHEN** module is called with sku="Basic"
- **THEN** Azure ML Workspace is created with Basic tier

#### Scenario: Create Enterprise ML workspace
- **WHEN** module is called with sku="Enterprise"
- **THEN** Azure ML Workspace is created with Enterprise tier features

### Requirement: Storage module
The system SHALL provide storage module that creates Azure Storage Account with globally unique name using random suffix.

#### Scenario: Create storage account
- **WHEN** storage module is called with resource group and location
- **THEN** storage account is created with sanitized name (no hyphens) and random suffix

### Requirement: Compute module
The system SHALL provide compute module for Azure ML compute resources.

#### Scenario: Define compute module structure
- **WHEN** compute module exists in modules/compute/
- **THEN** module contains main.tf, variables.tf, and outputs.tf for compute cluster configuration

### Requirement: Networking module
The system SHALL provide networking module for VNet and subnet configuration.

#### Scenario: Define networking module structure
- **WHEN** networking module exists in modules/networking/
- **THEN** module contains main.tf, variables.tf, and outputs.tf for network resources
