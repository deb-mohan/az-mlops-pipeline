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

# 4.2: Validate ENV parameter
ENV="${1:-}"
if [ -z "$ENV" ]; then
    print_error "Environment parameter is required"
    echo ""
    echo "Usage: $0 <environment>"
    echo "Example: $0 dev"
    echo ""
    echo "Valid environments: dev, test, prod, or custom"
    exit 1
fi

# Script starts here
print_header "Environment Initialization: $ENV"
echo "This script will initialize Terraform for the $ENV environment."
echo ""

# 4.3: Check environment file exists
ENV_FILE="infrastructure/terraform/environments/${ENV}.auto.tfvars"
print_info "Checking environment configuration..."
if [ ! -f "$ENV_FILE" ]; then
    print_error "Environment file not found: $ENV_FILE"
    echo ""
    echo "Available environments:"
    ls -1 infrastructure/terraform/environments/*.auto.tfvars 2>/dev/null | xargs -n 1 basename | sed 's/.auto.tfvars//' || echo "  (none found)"
    echo ""
    exit 1
fi
print_success "Environment file found: $ENV_FILE"

# 4.4: Copy .auto.tfvars file
print_info "Copying environment configuration..."
if cp "$ENV_FILE" "infrastructure/terraform/${ENV}.auto.tfvars"; then
    print_success "Configuration copied to infrastructure/terraform/${ENV}.auto.tfvars"
else
    print_error "Failed to copy configuration file"
    exit 1
fi

# Change to terraform directory
cd infrastructure/terraform

# 4.5 & 4.6: Initialize Terraform with backend config and reconfigure flag
print_header "Initializing Terraform"
print_info "Running terraform init..."
if terraform init -backend-config="key=${ENV}.terraform.tfstate" -reconfigure; then
    print_success "Terraform initialized successfully"
else
    print_error "Terraform initialization failed"
    exit 1
fi

# 4.7: Success message with next steps
print_header "Initialization Complete!"
echo ""
print_success "Terraform is initialized for the $ENV environment"
echo ""
echo "Backend state file: ${ENV}.terraform.tfstate"
echo "Configuration file: ${ENV}.auto.tfvars"
echo ""
echo "Next steps:"
echo "  1. Review planned changes: make plan ENV=$ENV"
echo "  2. Apply infrastructure: make apply ENV=$ENV"
echo ""
