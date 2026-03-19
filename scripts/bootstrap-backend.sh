#!/usr/bin/env bash
set -euo pipefail

# Helper functions
print_success() {
    echo "✓ $1"
}

print_error() {
    echo "✗ $1"
}

print_warning() {
    echo "⚠ $1"
}

print_info() {
    echo "ℹ $1"
}

print_header() {
    echo ""
    echo "=== $1 ==="
}

# Constants
BACKEND_TF="infrastructure/terraform/backend.tf"
CONTAINER="tfstate"
LOCATION="${1:-eastus}"
GENERATED_BACKEND=false

# Determine storage account name and resource group
if [ -f "$BACKEND_TF" ]; then
    # Parse existing backend.tf
    STORAGE_ACCOUNT=$(grep 'storage_account_name' "$BACKEND_TF" | sed -E 's/.*[=][[:space:]]*"([^"]+)".*/\1/')
    RESOURCE_GROUP=$(grep 'resource_group_name' "$BACKEND_TF" | head -1 | sed -E 's/.*[=][[:space:]]*"([^"]+)".*/\1/')

    if [ -z "$STORAGE_ACCOUNT" ] || [ -z "$RESOURCE_GROUP" ]; then
        print_error "Could not parse storage_account_name or resource_group_name from $BACKEND_TF"
        exit 1
    fi
    print_info "Found existing backend.tf"
else
    # Generate new names
    STORAGE_ACCOUNT="tfstate$(date +%s)"
    RESOURCE_GROUP="rg-tfstate-iemlops-${LOCATION}"
    GENERATED_BACKEND=true
    print_info "No backend.tf found — will generate with new storage account"
fi

# Script starts here
print_header "Azure Backend Bootstrap"
echo "This script will create Azure Storage backend for Terraform state management."
echo ""
print_info "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  Container: $CONTAINER"
echo "  Location: $LOCATION"
echo ""

# Check Azure CLI authentication
print_header "Checking Azure Authentication"
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure CLI"
    echo ""
    echo "Please login first:"
    echo "  az login"
    echo ""
    exit 1
fi
ACCOUNT_NAME=$(az account show --query name -o tsv)
print_success "Logged in to Azure: $ACCOUNT_NAME"

# Check/create resource group
print_header "Creating Backend Resources"
print_info "Checking resource group..."
if az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    print_success "Resource group '$RESOURCE_GROUP' already exists"
else
    print_warning "Creating resource group '$RESOURCE_GROUP'..."
    if az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none; then
        print_success "Resource group created"
    else
        print_error "Failed to create resource group"
        exit 1
    fi
fi

# Check/create storage account
print_info "Checking storage account..."
if az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    print_success "Storage account '$STORAGE_ACCOUNT' already exists"
else
    print_warning "Creating storage account '$STORAGE_ACCOUNT'..."
    if az storage account create \
        --name "$STORAGE_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku Standard_LRS \
        --encryption-services blob \
        --output none; then
        print_success "Storage account created"
    else
        print_error "Failed to create storage account"
        exit 1
    fi
fi

# Check/create container
print_info "Checking container..."
if az storage container show \
    --name "$CONTAINER" \
    --account-name "$STORAGE_ACCOUNT" \
    --auth-mode login &> /dev/null; then
    print_success "Container '$CONTAINER' already exists"
else
    print_warning "Creating container '$CONTAINER'..."
    if az storage container create \
        --name "$CONTAINER" \
        --account-name "$STORAGE_ACCOUNT" \
        --auth-mode login \
        --output none; then
        print_success "Container created"
    else
        print_error "Failed to create container"
        exit 1
    fi
fi

# Configure Azure authentication for Terraform backend
print_header "Configuring Backend Authentication"
print_info "Configuring Azure authentication for Terraform..."

CURRENT_USER=$(az account show --query user.name -o tsv)
print_info "Granting Storage Blob Data Contributor role to: $CURRENT_USER"

if az role assignment create \
    --role "Storage Blob Data Contributor" \
    --assignee "$CURRENT_USER" \
    --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT" \
    --output none 2>/dev/null; then
    print_success "Role assignment created"
else
    print_warning "Role assignment may already exist (this is normal)"
fi

# Generate backend.tf if it did not previously exist
if [ "$GENERATED_BACKEND" = true ]; then
    print_header "Generating backend.tf"
    cat > "$BACKEND_TF" << EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "${RESOURCE_GROUP}"
    storage_account_name = "${STORAGE_ACCOUNT}"
    container_name       = "${CONTAINER}"
    use_azuread_auth     = true
    # key is provided at init time:
    # terraform init -backend-config="key=<environment>.terraform.tfstate"
  }
}
EOF
    print_success "Generated $BACKEND_TF with storage account: $STORAGE_ACCOUNT"
fi

# Completion summary
print_header "Bootstrap Complete!"
echo ""
print_success "Azure backend storage is ready for Terraform state management"
echo ""
echo "Backend Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  Container: $CONTAINER"
echo "  Authentication: Azure CLI (no access keys)"
if [ "$GENERATED_BACKEND" = true ]; then
    echo "  backend.tf: Generated"
else
    echo "  backend.tf: Reused existing"
fi
echo ""
print_warning "Important: Terraform will use Azure CLI authentication"
echo "  - Local development: Ensure you are logged in with az login"
echo "  - CI/CD pipelines: Use managed identity or service principal"
echo ""
echo "Next steps:"
echo "  1. Initialize environment: make init-dev"
echo "  2. Plan infrastructure: make plan ENV=dev"
echo "  3. Apply infrastructure: make apply ENV=dev"
echo ""
