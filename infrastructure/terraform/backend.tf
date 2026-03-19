terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-iemlops-eastus"
    storage_account_name = "tfstate1773729419"
    container_name       = "tfstate"
    use_azuread_auth     = true
    # key is provided at init time:
    # terraform init -backend-config="key=<environment>.terraform.tfstate"
  }
}
