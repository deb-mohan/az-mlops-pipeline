output "workspace_id" {
  description = "ID of the Azure ML Workspace"
  value       = azurerm_machine_learning_workspace.main.id
}

output "workspace_name" {
  description = "Name of the Azure ML Workspace"
  value       = azurerm_machine_learning_workspace.main.name
}
