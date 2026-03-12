resource "azurerm_machine_learning_workspace" "main" {
  name                    = var.workspace_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = var.sku
  storage_account_id      = var.storage_account_id
  application_insights_id = var.application_insights_id
  key_vault_id            = var.key_vault_id

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
