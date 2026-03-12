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

# 5.2: Validate command parameter
COMMAND="${1:-}"
if [ -z "$COMMAND" ]; then
    print_error "Command parameter is required"
    echo ""
    echo "Usage: $0 <command> [ENV=<environment>] [additional flags]"
    echo "Commands: plan, apply, destroy, validate, fmt"
    exit 1
fi
shift

# 5.3: Validate ENV parameter for stateful operations
ENV=""
EXTRA_ARGS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        ENV=*)
            ENV="${1#*=}"
            shift
            ;;
        *)
            EXTRA_ARGS+=("$1")
            shift
            ;;
    esac
done

# Check if ENV is required for this command
if [[ "$COMMAND" == "plan" || "$COMMAND" == "apply" || "$COMMAND" == "destroy" ]]; then
    if [ -z "$ENV" ]; then
        print_error "ENV parameter is required for $COMMAND command"
        echo ""
        echo "Usage: $0 $COMMAND ENV=<environment>"
        echo "Example: $0 $COMMAND ENV=dev"
        exit 1
    fi
fi

# 5.6: Working directory management
TERRAFORM_DIR="infrastructure/terraform"
if [ ! -d "$TERRAFORM_DIR" ]; then
    print_error "Terraform directory not found: $TERRAFORM_DIR"
    exit 1
fi

cd "$TERRAFORM_DIR"

# 5.4: Check Terraform is initialized
if [ ! -d ".terraform" ]; then
    print_error "Terraform is not initialized"
    echo ""
    echo "Please run initialization first:"
    echo "  ${BLUE}make init-dev${NC} (or init-test, init-prod)"
    exit 1
fi

# 5.5: Verify .auto.tfvars file for stateful operations
if [[ "$COMMAND" == "plan" || "$COMMAND" == "apply" || "$COMMAND" == "destroy" ]]; then
    if [ ! -f "${ENV}.auto.tfvars" ]; then
        print_error "Configuration file not found: ${ENV}.auto.tfvars"
        echo ""
        echo "Please run initialization first:"
        echo "  ${BLUE}make init-${ENV}${NC}"
        exit 1
    fi
fi


# Execute commands based on type
case "$COMMAND" in
    # 5.7: Plan command
    plan)
        print_header "Terraform Plan: $ENV"
        terraform plan "${EXTRA_ARGS[@]}"
        ;;
    
    # 5.8: Apply command
    apply)
        print_header "Terraform Apply: $ENV"
        terraform apply "${EXTRA_ARGS[@]}"
        ;;
    
    # 5.9: Destroy command with confirmation
    destroy)
        print_header "Terraform Destroy: $ENV"
        print_warning "WARNING: This will destroy all resources in the $ENV environment!"
        echo ""
        echo -e "${RED}This action cannot be undone!${NC}"
        echo ""
        read -p "Press ENTER to continue or Ctrl+C to cancel..."
        echo ""
        terraform destroy "${EXTRA_ARGS[@]}"
        ;;
    
    # 5.10: Validate command
    validate)
        print_header "Terraform Validate"
        terraform validate "${EXTRA_ARGS[@]}"
        ;;
    
    # 5.11: Format command
    fmt)
        print_header "Terraform Format"
        terraform fmt -recursive "${EXTRA_ARGS[@]}"
        ;;
    
    *)
        print_error "Unknown command: $COMMAND"
        echo ""
        echo "Valid commands: plan, apply, destroy, validate, fmt"
        exit 1
        ;;
esac

# 5.12: Pass-through of additional flags is handled by EXTRA_ARGS array above
