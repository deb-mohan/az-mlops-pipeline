## Why

The current resource naming convention uses a `{project}-{environment}-{type}` suffix pattern (e.g., `iemlops-dev-rg`) which diverges from Azure's Cloud Adoption Framework (CAF) recommended `{type}-{project}-{environment}` prefix pattern (e.g., `rg-iemlops-dev`). Additionally, the backend state storage account uses a hardcoded name (`tfstateiemlops`) rather than the Azure-recommended `tfstate$RANDOM` pattern with a random numeric suffix for global uniqueness.

The bootstrap script also generates a `.env.local` file that nothing reads — a leftover from when it stored access keys (since removed as a security fix). The backend configuration values it contains are already present in `backend.tf`.

## What Changes

- Align all Terraform resource names in `main.tf` with CAF prefix convention
- Update `bootstrap-backend.sh` to generate `backend.tf` with a random-suffixed storage account name
- Make bootstrap idempotent: if `backend.tf` exists, parse the storage account name and verify it in Azure
- Remove `.env.local` generation from bootstrap script (keep `.env.local` in `.gitignore`)
- Update Application Insights abbreviation from `-ai` to `appi-` per CAF
- Update README.md and documentation references

## Capabilities

### Modified Capabilities
- `backend-bootstrap`: Bootstrap script generates `backend.tf` with randomized storage account name instead of using hardcoded values. Idempotent — parses existing `backend.tf` if present.
- `terraform-operations`: No functional changes, but resource names change due to CAF alignment.

## Impact

- Modified files: `infrastructure/terraform/main.tf`, `scripts/bootstrap-backend.sh`, `infrastructure/terraform/backend.tf` (now generated), `README.md`
- Removed behavior: `.env.local` file generation from bootstrap
- Breaking change: Resource names change pattern from suffix to prefix. Existing deployed resources would need to be destroyed and recreated, or imported under new names.
- Backend state storage: New deployments get a randomized storage account name. Existing deployments with a committed `backend.tf` continue to work unchanged.
