provider "azurerm" {
  features {}
  use_cli             = true
  storage_use_azuread = true
}

provider "azuread" {}
