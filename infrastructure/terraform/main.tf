terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate random suffix for globally unique resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false

  keepers = {
    environment = var.environment
  }
}

# Resource naming with environment-based convention
locals {
  resource_group_name = "${var.project_name}-${var.environment}-rg"
  ml_workspace_name   = "${var.project_name}-${var.environment}-mlw"

  # Storage account name: sanitized (no hyphens), with random suffix, max 24 chars
  storage_account_name = substr(
    replace("${var.project_name}${var.environment}${random_string.suffix.result}sa", "-", ""),
    0,
    24
  )

  # Common tags applied to all resources
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = var.project_name
    }
  )
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Storage Module
module "storage" {
  source = "./modules/storage"

  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  storage_account_name = local.storage_account_name
  tags                 = local.common_tags
}

# Application Insights for ML Workspace
resource "azurerm_application_insights" "main" {
  name                = "${var.project_name}-${var.environment}-ai"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  tags                = local.common_tags
}

# Key Vault for ML Workspace
resource "azurerm_key_vault" "main" {
  name                = substr("${var.project_name}-${var.environment}-kv-${random_string.suffix.result}", 0, 24)
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = local.common_tags
}

# Azure ML Workspace Module
module "ml_workspace" {
  source = "./modules/ml-workspace"

  resource_group_name     = azurerm_resource_group.main.name
  location                = var.location
  workspace_name          = local.ml_workspace_name
  sku                     = var.ml_workspace_sku
  storage_account_id      = module.storage.storage_account_id
  application_insights_id = azurerm_application_insights.main.id
  key_vault_id            = azurerm_key_vault.main.id
  tags                    = local.common_tags
}
