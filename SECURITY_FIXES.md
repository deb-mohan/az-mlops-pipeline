# Security Fixes Applied

This document summarizes the security vulnerabilities and crash risks identified by Q and the fixes applied.

## Issues Fixed

### 1. Storage Account Access Key in Plaintext (CWE-798)
**Severity**: Security Vulnerability  
**File**: `scripts/bootstrap-backend.sh`

**Issue**: Storage account access key was written to `.env.local` in plaintext, providing full access to Terraform state.

**Fix Applied**:
- Removed access key retrieval and storage
- Configured Azure AD authentication using `--auth-mode login`
- Added role assignment (Storage Blob Data Contributor) for current user
- Updated `.env.local` to store only configuration metadata (no credentials)
- Updated `backend.tf` with `use_azuread_auth = true`

**Benefits**:
- No credentials stored in plaintext
- Uses Azure CLI authentication for local development
- Supports managed identity/service principal for CI/CD
- Follows Azure security best practices

### 2. Script Downloaded Without Integrity Check (CWE-494)
**Severity**: Security Vulnerability  
**File**: `scripts/setup-tools.sh`

**Issue**: uv installation script was downloaded from internet and executed without signature or checksum verification.

**Fix Applied**:
- Changed installation method from `curl | sh` to Homebrew package
- Homebrew provides package verification and signing
- Added fallback instructions for manual installation with checksum verification

**Benefits**:
- Prevents supply chain attacks
- Uses trusted package manager with verification
- Provides secure alternative installation path

### 3. Empty Array Crash Risk (set -u)
**Severity**: Crash Risk  
**File**: `scripts/terraform-cmd.sh`

**Issue**: Referencing `"${EXTRA_ARGS[@]}"` causes 'unbound variable' error when `set -u` is active and no extra arguments provided.

**Fix Applied**:
- Changed all array references from `"${EXTRA_ARGS[@]}"` to `${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}`
- This syntax safely handles empty arrays with `set -u`

**Benefits**:
- Prevents script crashes when no extra arguments provided
- Maintains strict error checking with `set -u`
- Portable across different bash versions

### 4. Platform-Specific sed Behavior
**Severity**: Logic Error  
**File**: `scripts/bootstrap-backend.sh`

**Issue**: `sed -i.bak` behaves differently on macOS vs Linux, causing portability issues.

**Fix Applied**:
- Added platform detection using `$OSTYPE`
- Use `sed -i ''` for macOS
- Use `sed -i` for Linux
- Removed backup file creation logic (no longer needed)

**Benefits**:
- Works correctly on both macOS and Linux
- No leftover backup files
- Cleaner implementation

## Testing Recommendations

### Security Testing
1. Verify no credentials in `.env.local`:
   ```bash
   cat .env.local  # Should only contain config, no keys
   ```

2. Test Azure AD authentication:
   ```bash
   az login
   make bootstrap
   make init-dev
   ```

3. Verify Terraform uses Azure AD auth:
   ```bash
   # Should work without access keys
   make plan ENV=dev
   ```

### Crash Risk Testing
1. Test with no extra arguments:
   ```bash
   bash scripts/terraform-cmd.sh validate
   ```

2. Test with extra arguments:
   ```bash
   bash scripts/terraform-cmd.sh plan ENV=dev -target=azurerm_resource_group.main
   ```

### Platform Testing
1. Test on macOS:
   ```bash
   make bootstrap
   cat .env.local  # Verify correct format
   ```

2. Test on Linux:
   ```bash
   make bootstrap
   cat .env.local  # Verify correct format
   ```

## Security Best Practices Implemented

1. **No Hardcoded Credentials**: All authentication uses Azure AD
2. **Verified Package Installation**: Using Homebrew instead of curl scripts
3. **Strict Error Checking**: Maintained `set -euo pipefail` without crashes
4. **Platform Portability**: Cross-platform compatibility for macOS and Linux
5. **Least Privilege**: Role-based access control (RBAC) for storage access

## References

- CWE-798: Use of Hard-coded Credentials - https://cwe.mitre.org/data/definitions/798.html
- CWE-494: Download of Code Without Integrity Check - https://cwe.mitre.org/data/definitions/494.html
- Azure Storage Authentication: https://docs.microsoft.com/en-us/azure/storage/common/authorize-data-access
- Terraform Azure Backend: https://www.terraform.io/language/settings/backends/azurerm
