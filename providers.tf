terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.47"
    }

  }
  required_version = ">= 0.14.10"
  # features {}
}
provider "azurerm" {
  features {}
}


