variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, test, prod, or username for feature)"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "ml_workspace_sku" {
  description = "SKU for Azure ML Workspace (Basic or Enterprise)"
  type        = string
  default     = "Basic"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
