terraform {
  required_version = ">= 1.4.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.27.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.0"
    }
  }
}
