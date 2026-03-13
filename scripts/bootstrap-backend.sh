#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}===${NC} $1 ${BLUE}===${NC}"
}

# Backend configuration (from backend.tf)
RESOURCE_GROUP="terraform-state-rg"
STORAGE_ACCOUNT="tfstateiemlops"
CONTAINER="tfstate"
LOCATION="${1:-eastus}"  # 3.3: Default location parameter

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

# 3.2: Check Azure CLI authentication
print_header "Checking Azure Authentication"
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure CLI"
    echo ""
    echo "Please login first:"
    echo "  ${BLUE}az login${NC}"
    echo ""
    exit 1
fi
ACCOUNT_NAME=$(az account show --query name -o tsv)
print_success "Logged in to Azure: $ACCOUNT_NAME"

# 3.4: Check/create resource group
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

# 3.5: Check/create storage account
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

# 3.6: Check/create container
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

# 3.7: Configure Azure authentication for Terraform backend
print_header "Configuring Backend Authentication"
print_info "Configuring Azure authentication for Terraform..."

# Grant current user Storage Blob Data Contributor role on the storage account
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

# 3.8: Create .env.local with authentication mode configuration
print_info "Creating .env.local with secure authentication configuration..."
cat > .env.local << 'EOF'
# Azure Backend Authentication Configuration
# Terraform will use Azure CLI authentication (no access keys stored)
# Ensure you are logged in with: az login

# Backend configuration
BACKEND_RESOURCE_GROUP="terraform-state-rg"
BACKEND_STORAGE_ACCOUNT="tfstateiemlops"
BACKEND_CONTAINER="tfstate"

# Authentication: Use Azure CLI (managed identity in CI/CD)
# No access keys stored - uses --auth-mode login
EOF

# Update with actual values
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|terraform-state-rg|$RESOURCE_GROUP|g" .env.local
    sed -i '' "s|tfstateiemlops|$STORAGE_ACCOUNT|g" .env.local
    sed -i '' "s|tfstate|$CONTAINER|g" .env.local
else
    # Linux
    sed -i "s|terraform-state-rg|$RESOURCE_GROUP|g" .env.local
    sed -i "s|tfstateiemlops|$STORAGE_ACCOUNT|g" .env.local
    sed -i "s|tfstate|$CONTAINER|g" .env.local
fi

print_success ".env.local created with secure configuration"

# 3.9: Display completion summary
print_header "Bootstrap Complete!"
echo ""
print_success "Azure backend storage is ready for Terraform state management"
echo ""
echo "Backend Configuration:"
echo "  Resource Group: ${BLUE}$RESOURCE_GROUP${NC}"
echo "  Storage Account: ${BLUE}$STORAGE_ACCOUNT${NC}"
echo "  Container: ${BLUE}$CONTAINER${NC}"
echo "  Authentication: ${GREEN}Azure CLI (no access keys)${NC}"
echo ""
print_warning "Important: Terraform will use Azure CLI authentication"
echo "  - Local development: Ensure you are logged in with ${BLUE}az login${NC}"
echo "  - CI/CD pipelines: Use managed identity or service principal"
echo ""
echo "Next steps:"
echo "  1. Initialize environment: ${BLUE}make init-dev${NC}"
echo "  2. Plan infrastructure: ${BLUE}make plan ENV=dev${NC}"
echo "  3. Apply infrastructure: ${BLUE}make apply ENV=dev${NC}"
echo ""
