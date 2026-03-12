terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateiemlops"
    container_name       = "tfstate"
    use_azuread_auth     = true  # Use Azure AD authentication instead of access keys
    # key is provided at init time:
    # terraform init -backend-config="key=<environment>.terraform.tfstate"
  }
}
