variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the ML workspace"
  type        = string
}

variable "workspace_name" {
  description = "Name of the Azure ML Workspace"
  type        = string
}

variable "sku" {
  description = "SKU for the ML Workspace (Basic or Enterprise)"
  type        = string
  default     = "Basic"
}

variable "storage_account_id" {
  description = "ID of the storage account for the ML workspace"
  type        = string
}

variable "application_insights_id" {
  description = "ID of the Application Insights for the ML workspace"
  type        = string
}

variable "key_vault_id" {
  description = "ID of the Key Vault for the ML workspace"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the ML workspace"
  type        = map(string)
  default     = {}
}
