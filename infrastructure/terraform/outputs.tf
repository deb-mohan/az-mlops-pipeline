output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

output "ml_workspace_id" {
  description = "ID of the Azure ML Workspace"
  value       = module.ml_workspace.workspace_id
}

output "ml_workspace_name" {
  description = "Name of the Azure ML Workspace"
  value       = module.ml_workspace.workspace_name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = module.storage.storage_account_id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.storage.storage_account_name
}
