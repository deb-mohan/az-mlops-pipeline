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

# 3.7: Retrieve storage account access key
print_header "Retrieving Access Key"
print_info "Getting storage account access key..."
STORAGE_KEY=$(az storage account keys list \
    --resource-group "$RESOURCE_GROUP" \
    --account-name "$STORAGE_ACCOUNT" \
    --query '[0].value' \
    --output tsv)

if [ -z "$STORAGE_KEY" ]; then
    print_error "Failed to retrieve storage account key"
    exit 1
fi
print_success "Access key retrieved"

# 3.8: Save to .env.local
print_info "Saving access key to .env.local..."
if [ -f ".env.local" ]; then
    # Update existing file
    if grep -q "STORAGE_ACCOUNT_KEY=" .env.local; then
        sed -i.bak "s|STORAGE_ACCOUNT_KEY=.*|STORAGE_ACCOUNT_KEY=$STORAGE_KEY|" .env.local
        rm -f .env.local.bak
        print_success ".env.local updated"
    else
        echo "STORAGE_ACCOUNT_KEY=$STORAGE_KEY" >> .env.local
        print_success "Access key added to .env.local"
    fi
else
    # Create new file
    echo "STORAGE_ACCOUNT_KEY=$STORAGE_KEY" > .env.local
    print_success ".env.local created"
fi

# 3.9: Display completion summary
print_header "Bootstrap Complete!"
echo ""
print_success "Azure backend storage is ready for Terraform state management"
echo ""
echo "Backend Configuration:"
echo "  Resource Group: ${BLUE}$RESOURCE_GROUP${NC}"
echo "  Storage Account: ${BLUE}$STORAGE_ACCOUNT${NC}"
echo "  Container: ${BLUE}$CONTAINER${NC}"
echo "  Access Key: Saved to ${BLUE}.env.local${NC}"
echo ""
echo "Next steps:"
echo "  1. Initialize environment: ${BLUE}make init-dev${NC}"
echo "  2. Plan infrastructure: ${BLUE}make plan ENV=dev${NC}"
echo "  3. Apply infrastructure: ${BLUE}make apply ENV=dev${NC}"
echo ""
