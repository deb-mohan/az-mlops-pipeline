## Context

This design establishes the foundational Terraform infrastructure for an Azure MLOps pipeline. The project follows a phased approach: Phase 1 (current) builds infrastructure, Phase 2 adds GitHub Actions automation, and Phase 3 implements ML pipeline workflows. The infrastructure must support multiple static environments (dev, test, prod) and dynamic feature branch environments for parallel development.

Current state: Empty repository with no existing infrastructure. Team has experience with AWS/ECS Fargate using similar patterns. Constraints include: no code duplication across environments, secrets stored in GitHub organization (not in repo), and use of modern Python tooling (uv) for local development.

Stakeholders: ML engineering team (will use the infrastructure), platform team (maintains Terraform), and developers (create feature branch environments).

## Goals / Non-Goals

**Goals:**
- Create DRY Terraform infrastructure with single source of truth (main.tf) and environment-specific variable files
- Support static environments (dev, test, prod) and dynamic feature branch environments (username-based)
- Implement modular architecture with reusable components for Azure ML Workspace, Storage, Compute, and Networking
- Establish quality gates with TFLint and pre-commit hooks to prevent secrets and enforce best practices
- Enable isolated state management per environment using Azure Storage backend
- Provide consistent resource naming with global uniqueness for storage accounts using random provider
- Set up Python tooling environment using uv/venv for pre-commit framework

**Non-Goals:**
- GitHub Actions workflows (Phase 2)
- MLOps pipeline implementation (Phase 3)
- Azure Functions or ML training code
- Monitoring and alerting setup
- Actual GitHub repository creation (user responsibility)

## Decisions

### Decision 1: Monorepo Pattern 1 (Flat Separation)
**Choice:** Use top-level separation with infrastructure/, src/, .github/, docs/, tests/ directories.

**Rationale:** 
- Clear boundaries between infrastructure and application code
- Easy navigation for developers familiar with monorepo patterns
- Supports GitHub Actions path filters for targeted CI/CD
- Scales naturally when ML pipeline code is added in Phase 3
- Team has successful experience with this pattern in AWS/ECS Fargate projects

**Alternatives considered:**
- Domain-driven structure (platform/, data-ingestion/, model-training/): Too complex for starting out, better suited for microservices with multiple teams
- Microsoft's Azure ML reference pattern (data/, models/, operations/): ML-specific but less flexible for mixed infrastructure/application code

### Decision 2: DRY Multi-Environment with .auto.tfvars
**Choice:** Single main.tf with environment-specific .auto.tfvars files in environments/ directory.

**Rationale:**
- Zero code duplication - changes apply to all environments automatically
- Terraform auto-loads .auto.tfvars files without -var-file flag
- Easy to add new environments (copy template, update values)
- Clear separation of code (main.tf) and configuration (.auto.tfvars)
- Non-sensitive config can be committed to repo safely

**Alternatives considered:**
- Environment-based folders (environments/dev/, environments/test/): Causes code duplication, harder to keep in sync
- Workspace-based with single config: Workspace switching error-prone, state management complexity
- Separate repos per environment: Extreme isolation but massive overhead

### Decision 3: Partial Backend Configuration
**Choice:** Use partial backend config in backend.tf with dynamic key provided at terraform init.

**Rationale:**
- Supports dynamic environment names (dev, test, prod, username)
- Separate state file per environment prevents cross-contamination
- Works with feature branch environments where names are not known in advance
- Clean separation: static config in backend.tf, dynamic key at runtime

**Alternatives considered:**
- Separate backend.hcl files per environment: Doesn't support dynamic feature branch names
- Variables in backend config: Not allowed by Terraform
- Terraform Cloud: Adds external dependency and cost

**Implementation:**
```hcl
# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateiemlops"
    container_name       = "tfstate"
    # key provided at init: terraform init -backend-config="key=dev.terraform.tfstate"
  }
}
```

### Decision 4: Random Provider for Storage Account Naming
**Choice:** Use random_string resource with environment keeper to generate consistent suffix for storage accounts.

**Rationale:**
- Azure storage account names are globally unique (3-24 chars, lowercase alphanumeric)
- Prevents naming conflicts when multiple developers deploy feature branches
- Keeper ensures same suffix for same environment across applies
- New suffix generated when environment changes (prevents stale resources)

**Alternatives considered:**
- Manual suffix in variable: Requires coordination, prone to conflicts
- Timestamp-based suffix: Changes on every apply, causes resource recreation
- No suffix: High risk of naming conflicts in global namespace

**Implementation:**
```hcl
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  keepers = {
    environment = var.environment
  }
}

locals {
  storage_account_name = substr(
    replace("${var.project_name}${var.environment}${random_string.suffix.result}sa", "-", ""),
    0, 24
  )
}
```

### Decision 5: TFLint with Azure Ruleset
**Choice:** Use TFLint with azurerm plugin and security rules for local and CI/CD validation.

**Rationale:**
- Detects hardcoded secrets before commit (terraform_sensitive_variable_no_default)
- Enforces Azure best practices (azurerm ruleset)
- Validates naming conventions and required tags
- Catches errors early in development cycle
- Industry standard for Terraform quality gates

**Alternatives considered:**
- Checkov: More comprehensive but slower, overkill for initial phase
- Terraform validate only: Doesn't catch security issues or best practice violations
- Manual code review only: Not scalable, inconsistent

### Decision 6: Pre-commit Framework with uv
**Choice:** Use pre-commit framework installed via uv in virtual environment.

**Rationale:**
- Automatic validation on git commit (terraform fmt, validate, tflint)
- Prevents secrets from being committed (detect-private-key hook)
- uv is faster than pip and team prefers modern Python tooling
- Virtual environment isolates dependencies from system Python
- Consistent developer experience across team

**Alternatives considered:**
- Manual git hooks: Hard to maintain, not portable across team
- pip instead of uv: Slower, less modern
- No local validation: Relies only on CI/CD, slower feedback loop

**Implementation:**
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
      - id: terraform_docs
  - repo: https://github.com/pre-commit/pre-commit-hooks
    hooks:
      - id: detect-private-key
      - id: check-merge-conflict
```

### Decision 7: Module Structure
**Choice:** Create separate modules for ml-workspace, storage, compute, and networking with standard structure (main.tf, variables.tf, outputs.tf).

**Rationale:**
- Reusable across environments and future projects
- Clear separation of concerns
- Easy to test modules independently
- Standard Terraform module pattern
- Aligns with Azure ML architecture (workspace, storage, compute, network)

**Alternatives considered:**
- Monolithic main.tf: Hard to maintain, no reusability
- External modules from registry: Less control, may not fit requirements
- Nested modules: Adds complexity without clear benefit

### Decision 8: Resource Naming Convention
**Choice:** Use pattern `<project>-<environment>-<resource-type>` for standard resources, with random suffix for globally unique resources.

**Rationale:**
- Easy to identify environment and purpose at a glance
- Consistent across all resources
- Supports feature branch naming (iemlops-johndoe-rg)
- Aligns with Azure naming best practices
- Random suffix only where needed (storage accounts) keeps names readable

**Alternatives considered:**
- Reverse order (rg-dev-iemlops): Less readable
- Abbreviations only (mmo-d-rg): Hard to understand
- No environment in name: Can't distinguish resources across environments

**Examples:**
- Resource Group: iemlops-dev-rg
- ML Workspace: iemlops-dev-mlw
- Storage Account: iemlopsdevab12c3sa (with random suffix)

### Decision 9: Secrets Management Strategy
**Choice:** Commit non-sensitive config (.auto.tfvars) to repo, store secrets in GitHub organization secrets.

**Rationale:**
- Clear separation: configuration is code, secrets are runtime
- GitHub organization secrets provide centralized management
- Secrets injected at runtime via environment variables (ARM_CLIENT_ID, etc.)
- No risk of accidentally committing secrets
- Supports different secrets per environment

**Alternatives considered:**
- Azure Key Vault for all config: Overkill, slows local development
- Encrypted secrets in repo: Complex key management, rotation issues
- Local .env files: Not portable, easy to commit accidentally

**What goes where:**
- In repo (.auto.tfvars): project_name, environment, location, SKUs, tags
- In GitHub Secrets: ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID

## Risks / Trade-offs

**Risk: Storage account name length limit (24 chars)**
- Mitigation: Use substr() to truncate combined name, remove hyphens. Test with longest expected environment names.

**Risk: Random suffix changes cause resource recreation**
- Mitigation: Use keepers to tie suffix to environment variable. Document that changing environment name triggers new resources.

**Risk: Terraform state file conflicts in Azure Storage**
- Mitigation: Use separate state file per environment with dynamic key. Document init command pattern.

**Risk: Developers forget to run pre-commit install**
- Mitigation: Document in README setup steps. Consider adding check in CI/CD to verify commits passed pre-commit.

**Risk: TFLint rules too strict, block legitimate code**
- Mitigation: Start with recommended preset, adjust rules based on team feedback. Document exceptions in .tflint.hcl.

**Risk: Feature branch environments not cleaned up**
- Mitigation: Document cleanup process. Consider adding tags for auto-cleanup in future (out of scope for Phase 1).

**Risk: Module changes affect all environments**
- Mitigation: Test in dev first, use Terraform plan before apply. Consider module versioning in future if needed.

**Trade-off: Single main.tf vs environment folders**
- Chosen: Single main.tf for DRY principle
- Trade-off: Less isolation between environments, but easier to maintain consistency
- Acceptable because: Separate state files provide isolation, benefits of DRY outweigh risks

**Trade-off: Partial backend config vs separate backend files**
- Chosen: Partial backend config for flexibility
- Trade-off: Requires remembering to pass -backend-config flag
- Acceptable because: Enables dynamic environments, can be scripted in GitHub Actions

**Trade-off: Pre-commit hooks vs CI/CD only**
- Chosen: Both (pre-commit for fast feedback, CI/CD as gate)
- Trade-off: Developers must install pre-commit, adds setup step
- Acceptable because: Catches issues earlier, reduces CI/CD failures

## Migration Plan

**Phase 1 Implementation (Current):**
1. Create repository structure (infrastructure/, src/, docs/, tests/, .github/)
2. Create Terraform root files (main.tf, variables.tf, outputs.tf, backend.tf)
3. Create Terraform modules (ml-workspace, storage, compute, networking)
4. Create environment variable files (dev.auto.tfvars, test.auto.tfvars, prod.auto.tfvars, feature.auto.tfvars.template)
5. Create quality gate configs (.tflint.hcl, .pre-commit-config.yaml)
6. Create Python project files (pyproject.toml, .python-version)
7. Create .gitignore with appropriate exclusions
8. Create README.md with setup instructions
9. Test locally with dev environment
10. Validate with test and prod configurations

**Deployment Steps:**
1. Developer clones repository
2. Runs uv venv && source .venv/bin/activate
3. Runs uv pip install pre-commit && pre-commit install
4. Runs cd infrastructure/terraform && tflint --init
5. Copies appropriate .auto.tfvars file (or creates from template)
6. Runs terraform init -backend-config="key=<env>.terraform.tfstate"
7. Runs terraform plan to preview changes
8. Runs terraform apply to create resources

**Rollback Strategy:**
- Terraform state is preserved in Azure Storage
- Run terraform destroy to remove resources
- State file remains for audit trail
- Can recreate from same state file if needed

**Validation:**
- Pre-commit hooks pass on all files
- TFLint reports no critical issues
- Terraform plan succeeds for all environments
- Terraform apply succeeds in dev environment
- Resources created with correct naming convention
- Tags applied correctly to all resources

## Open Questions

**Q: What specific compute resources are needed in the compute module?**
- Answer needed before implementing compute module details
- Options: Azure ML Compute Clusters, Compute Instances, or both
- Decision: Defer to implementation phase, create module structure now

**Q: What networking configuration is required?**
- Answer needed before implementing networking module details
- Options: Public access, private endpoints, VNet integration
- Decision: Defer to implementation phase, create module structure now

**Q: Should we version Terraform modules?**
- Not needed for Phase 1 (single team, rapid iteration)
- Revisit in Phase 2 when stability increases

**Q: What Azure region(s) should be supported?**
- Default to eastus in examples
- Make configurable via location variable
- Document multi-region support as future enhancement
