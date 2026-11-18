# Same backend storage as "Azure Workspaces Demo" (same RG, account, container).
# Only the "key" is different, so the state of this project never mixes with that one.
#
# Each workspace gets its own state blob in the container:
#   azure-workspaces-github-modules/terraform.tfstateenv:dev
#   azure-workspaces-github-modules/terraform.tfstateenv:prod

terraform {
  backend "azurerm" {
    resource_group_name  = "amazonsa"
    storage_account_name = "amazonsa198"
    container_name       = "statefile"
    key                  = "azure-workspaces-github-modules/terraform.tfstate"
  }
}
