## Technical Design

### Architecture Overview

The developer automation tooling follows a layered architecture:

1. **User Interface Layer**: Makefile with developer-friendly targets
2. **Orchestration Layer**: Bash scripts that implement business logic
3. **Tool Layer**: External tools (terraform, tflint, az, func) invoked by scripts
4. **Configuration Layer**: Environment-specific .auto.tfvars files and .env.local

### Component Design

#### 1. Makefile Interface

**Location**: `Makefile` (project root)

**Purpose**: Provide simple, memorable commands for developers

**Key Targets**:
- `help` (default): Display all available commands
- `setup`: Install all required tools
- `bootstrap`: Create Azure backend storage
- `init-<env>`: Initialize Terraform for specific environment (dev, test, prod)
- `plan ENV=<env>`: Run terraform plan
- `apply ENV=<env>`: Run terraform apply
- `destroy ENV=<env>`: Run terraform destroy with confirmation
- `validate`: Run terraform validate
- `fmt`: Format terraform files
- `lint`: Run tflint
- `clean`: Remove local terraform state and cache
- `quickstart ENV=<env>`: One-command setup (setup + bootstrap + init)

**Design Decisions**:
- Use `.PHONY` for all targets to prevent conflicts with files
- Use `@` prefix to suppress command echo for cleaner output
- Implement prerequisite checking before tool-dependent commands
- Use colored output for better UX (green for success, red for errors, yellow for warnings)
- Require explicit ENV parameter for environment-specific operations

#### 2. Tool Installation Script

**Location**: `scripts/setup-tools.sh`

**Purpose**: Automate installation of required development tools

**Flow**:
```
1. Verify Homebrew is installed (exit if not)
2. Check and install Terraform
3. Check and install TFLint
4. Check and install Azure CLI
5. Check and install Azure Functions Core Tools v4
6. Check and install uv (Python package manager)
7. Create Python virtual environment (.venv)
8. Install Python dependencies from pyproject.toml
9. Install pre-commit hooks
10. Initialize TFLint plugins
11. Display completion summary
```

**Design Decisions**:
- Check-first-then-install pattern to avoid unnecessary operations
- Display tool versions for verification
- Use `command -v` for portable tool detection
- Exit on critical failures (Homebrew missing)
- Continue on non-critical failures with warnings

#### 3. Backend Bootstrap Script

**Location**: `scripts/bootstrap-backend.sh`

**Purpose**: Create Azure backend storage for Terraform state

**Flow**:
```
1. Verify Azure CLI authentication
2. Check/create resource group (terraform-state-rg)
3. Check/create storage account (tfstateiemlops)
4. Check/create container (tfstate)
5. Retrieve storage account access key
6. Save access key to .env.local
7. Display completion summary
```

**Hardcoded Values** (from backend.tf):
- Resource Group: `terraform-state-rg`
- Storage Account: `tfstateiemlops`
- Container: `tfstate`
- Location: `eastus` (configurable via parameter)

**Design Decisions**:
- Idempotent operations using `az <resource> show` before create
- Store access key in .env.local (gitignored) for developer convenience
- Use Standard_LRS SKU for cost optimization
- Exit on authentication failure
- Continue if resources already exist

#### 4. Environment Initialization Script

**Location**: `scripts/init-env.sh`

**Purpose**: Initialize Terraform with environment-specific configuration

**Parameters**:
- `ENV`: Environment name (dev, test, prod, or custom)

**Flow**:
```
1. Validate ENV parameter
2. Verify environments/<ENV>.auto.tfvars exists
3. Copy <ENV>.auto.tfvars to infrastructure/terraform/
4. Change to infrastructure/terraform directory
5. Run terraform init -backend-config="key=<ENV>.terraform.tfstate" -reconfigure
6. Display success message with next steps
```

**Design Decisions**:
- Use `-reconfigure` flag to support switching between environments
- Validate environment file exists before copying
- Use environment-specific state file keys for isolation
- Display clear error messages for missing files

#### 5. Terraform Operations Wrapper

**Location**: `scripts/terraform-cmd.sh`

**Purpose**: Wrap terraform commands with validation and safety checks

**Parameters**:
- `COMMAND`: Terraform command (plan, apply, destroy, validate, fmt)
- `ENV`: Environment name (required for plan, apply, destroy)
- Additional flags passed through to terraform

**Flow**:
```
1. Validate required parameters
2. Check Terraform is initialized (.terraform directory exists)
3. Verify correct .auto.tfvars file is present
4. For destroy: Display warning and require confirmation
5. Execute terraform command with pass-through flags
6. Display results
```

**Design Decisions**:
- Require ENV parameter for stateful operations
- Allow ENV to be optional for validate and fmt
- Pass through additional flags to terraform
- Add confirmation step for destructive operations
- Check initialization state before operations

### File Structure

```
project-root/
├── Makefile                          # User interface
├── scripts/
│   ├── setup-tools.sh                # Tool installation
│   ├── bootstrap-backend.sh          # Backend creation
│   ├── init-env.sh                   # Environment initialization
│   └── terraform-cmd.sh              # Terraform wrapper
├── infrastructure/terraform/
│   ├── main.tf
│   ├── backend.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── .tflint.hcl
│   ├── environments/
│   │   ├── dev.auto.tfvars
│   │   ├── test.auto.tfvars
│   │   ├── prod.auto.tfvars
│   │   └── feature.auto.tfvars.template
│   └── modules/
├── .env.local                        # Local secrets (gitignored)
├── .gitignore                        # Updated to include .env.local
└── README.md                         # Updated with new workflow

```

### Configuration Management

#### Environment Variables (.env.local)

**Purpose**: Store local secrets that should not be committed

**Contents**:
```bash
STORAGE_ACCOUNT_KEY=<access-key>
```

**Security**:
- Added to .gitignore
- Created by bootstrap script
- Used for manual backend access if needed

#### Environment-Specific Variables (.auto.tfvars)

**Purpose**: Define environment-specific Terraform variables

**Location**: `infrastructure/terraform/environments/`

**Files**:
- `dev.auto.tfvars`: Development environment
- `test.auto.tfvars`: Test environment
- `prod.auto.tfvars`: Production environment
- `feature.auto.tfvars.template`: Template for feature branches

**Usage**: Copied to `infrastructure/terraform/` during init

### Error Handling Strategy

1. **Validation Errors**: Exit early with clear error message
2. **Tool Missing**: Display installation instructions and exit
3. **Authentication Errors**: Display login instructions and exit
4. **Resource Creation Errors**: Display Azure error message and exit
5. **Terraform Errors**: Pass through terraform error messages

### User Experience Design

#### Color Coding
- Green: Success messages
- Red: Error messages
- Yellow: Warning messages
- Blue: Informational messages

#### Progress Indicators
- Display current step during multi-step operations
- Show tool versions after installation
- Display resource names after creation

#### Help and Documentation
- `make help` displays all commands with descriptions
- Error messages include suggested next steps
- README.md updated with new workflow

### Workflow Integration

#### New Developer Onboarding
```bash
make quickstart ENV=dev
```

This single command:
1. Installs all tools
2. Creates backend storage
3. Initializes dev environment

#### Daily Development Workflow
```bash
make plan ENV=dev      # Review changes
make apply ENV=dev     # Apply changes
make destroy ENV=dev   # Clean up (with confirmation)
```

#### Environment Switching
```bash
make init-test         # Switch to test
make plan ENV=test     # Plan for test
make apply ENV=test    # Apply to test
```

### Testing Strategy

#### Manual Testing Checklist
- [ ] Run `make setup` on clean machine
- [ ] Run `make bootstrap` with and without Azure login
- [ ] Run `make init-dev`, `make init-test`, `make init-prod`
- [ ] Run `make plan ENV=dev` before and after init
- [ ] Run `make apply ENV=dev` and verify resources created
- [ ] Run `make destroy ENV=dev` and verify confirmation required
- [ ] Run `make validate`, `make fmt`, `make lint`
- [ ] Run `make clean` and verify files removed
- [ ] Run `make quickstart ENV=dev` on clean machine
- [ ] Test error cases: missing ENV, invalid ENV, missing tools

#### Idempotency Testing
- Run bootstrap twice, verify no errors
- Run setup twice, verify tools not reinstalled
- Run init twice, verify reconfiguration works

### Future Enhancements

1. **Windows Support**: PowerShell versions of bash scripts
2. **GPG Code Signing**: Add to prerequisites with GitHub docs
3. **CI/CD Integration**: GitHub Actions workflows
4. **Multi-region Support**: Add region parameter to bootstrap
5. **State Locking**: Add lock table configuration
6. **Cost Estimation**: Integrate terraform cost estimation tools
7. **Drift Detection**: Scheduled drift detection jobs
8. **Automated Testing**: Terratest integration
