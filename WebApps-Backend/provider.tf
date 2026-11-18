terraform {
  required_version = ">=1.12"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">5.0"
    }
  }
    backend "azurerm" {
      resource_group_name = "StageRG"
      storage_account_name = "terraformstatergamex90"
      container_name = "tfstate"
      key = "prod.terraform.tfstate"
    }

}


provider "azurerm" {
  features {}
}
