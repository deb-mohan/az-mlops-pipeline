## MODIFIED Requirements

### Requirement: Resource naming follows Azure CAF prefix convention
The system SHALL name all Azure resources using the CAF prefix pattern `{type}-{project}-{environment}`.

#### Scenario: Resource group naming
- **WHEN** Terraform creates a resource group for project "iemlops" in environment "dev"
- **THEN** the resource group name is `rg-iemlops-dev`

#### Scenario: ML workspace naming
- **WHEN** Terraform creates an ML workspace for project "iemlops" in environment "dev"
- **THEN** the workspace name is `mlw-iemlops-dev`

#### Scenario: Application Insights naming
- **WHEN** Terraform creates Application Insights for project "iemlops" in environment "dev"
- **THEN** the name is `appi-iemlops-dev`

#### Scenario: Key Vault naming
- **WHEN** Terraform creates a Key Vault for project "iemlops" in environment "dev" with random suffix "abc123"
- **THEN** the name is `kv-iemlops-dev-abc123` (truncated to 24 chars)

#### Scenario: Storage account naming
- **WHEN** Terraform creates a storage account for project "iemlops" in environment "dev" with random suffix "abc123"
- **THEN** the name is `stiemlopsdevabc123` (no hyphens, truncated to 24 chars, prefixed with `st`)

### Requirement: README documents CAF naming convention
The system SHALL document the CAF prefix naming pattern in README.md.

#### Scenario: Naming convention section updated
- **WHEN** a developer reads the Resource Naming Convention section
- **THEN** it shows the pattern `{type}-{project}-{environment}` with CAF-aligned examples
