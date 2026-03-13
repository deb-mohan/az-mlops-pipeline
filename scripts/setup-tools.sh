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

# Script starts here
print_header "Developer Tools Setup"
echo "This script will install required development tools for the Azure MLOps project."
echo ""

# 2.2: Verify Homebrew is installed
print_header "Checking Prerequisites"
if ! command -v brew &> /dev/null; then
    print_error "Homebrew is not installed"
    echo ""
    echo "Please install Homebrew first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo ""
    exit 1
fi
print_success "Homebrew is installed: $(brew --version | head -n 1)"

# 2.3: Check-and-install function for tools
check_and_install() {
    local tool_name=$1
    local brew_package=$2
    local check_command=${3:-$tool_name}
    
    print_info "Checking $tool_name..."
    if command -v "$check_command" &> /dev/null; then
        local version=$("$check_command" --version 2>&1 | head -n 1)
        print_success "$tool_name is already installed: $version"
        return 0
    else
        print_warning "$tool_name not found. Installing..."
        if brew install "$brew_package"; then
            print_success "$tool_name installed successfully"
            return 0
        else
            print_error "Failed to install $tool_name"
            return 1
        fi
    fi
}

# 2.4: Install Terraform
print_header "Installing Development Tools"
check_and_install "Terraform" "terraform" "terraform"

# 2.5: Install TFLint
check_and_install "TFLint" "tflint" "tflint"

# 2.6: Install Azure CLI
check_and_install "Azure CLI" "azure-cli" "az"

# 2.7: Install Azure Functions Core Tools v4
check_and_install "Azure Functions Core Tools" "azure-functions-core-tools@4" "func"

# 2.8: Install uv (Python package manager)
print_header "Setting Up Python Environment"
print_info "Checking uv..."
if command -v uv &> /dev/null; then
    print_success "uv is already installed: $(uv --version)"
else
    print_warning "uv not found. Installing via Homebrew (verified package)..."
    # Use Homebrew instead of curl script for better security
    if brew install uv; then
        print_success "uv installed successfully"
    else
        print_error "Failed to install uv via Homebrew"
        echo ""
        print_warning "Alternative: Install manually with checksum verification"
        echo "  Visit: https://docs.astral.sh/uv/getting-started/installation/"
        exit 1
    fi
fi

# 2.9: Create Python virtual environment
print_info "Checking Python virtual environment..."
if [ -d ".venv" ]; then
    print_success "Virtual environment already exists"
else
    print_warning "Creating virtual environment..."
    if uv venv; then
        print_success "Virtual environment created"
    else
        print_error "Failed to create virtual environment"
        exit 1
    fi
fi

# 2.10: Install Python dependencies using uv
print_info "Installing Python dependencies..."
if uv pip install -e .; then
    print_success "Python dependencies installed"
else
    print_error "Failed to install Python dependencies"
    exit 1
fi

# 2.11: Install pre-commit hooks
print_header "Configuring Git Hooks"
print_info "Installing pre-commit hooks..."
if source .venv/bin/activate && pre-commit install; then
    print_success "Pre-commit hooks installed"
else
    print_warning "Failed to install pre-commit hooks (non-critical)"
fi

# 2.12: Initialize TFLint
print_header "Initializing TFLint"
print_info "Downloading TFLint plugins..."
cd infrastructure/terraform
if tflint --init; then
    print_success "TFLint initialized"
else
    print_warning "Failed to initialize TFLint (non-critical)"
fi
cd ../..

# 2.13: Display completion summary
print_header "Setup Complete!"
echo ""
print_success "All development tools have been installed successfully"
echo ""
echo "Next steps:"
echo "  1. Authenticate with Azure: ${BLUE}az login${NC}"
echo "  2. Bootstrap backend storage: ${BLUE}make bootstrap${NC}"
echo "  3. Initialize environment: ${BLUE}make init-dev${NC}"
echo "  4. Plan infrastructure: ${BLUE}make plan ENV=dev${NC}"
echo ""
echo "Or use the quickstart command:"
echo "  ${BLUE}make quickstart ENV=dev${NC}"
echo ""
