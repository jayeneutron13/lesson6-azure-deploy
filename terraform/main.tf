terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.6"
    }
  }

  required_version = ">= 1.4"

  backend "azurerm" {
    resource_group_name  = "tfstate-rg-ddf"
    storage_account_name = "tfstatedurnellfisher"
    container_name       = "tfstatedurnellfisher"
    key                  = "lesson6.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

locals {
  location      = "East US"
  app_base_name = "lesson6-html-app"
  app_name      = "${local.app_base_name}-${random_string.suffix.result}"
}

resource "azurerm_resource_group" "rg" {
  name     = "lesson6-rg-ddf"
  location = local.location
}

resource "azurerm_service_plan" "plan" {
  name                = "lesson6-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = local.app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    app_command_line = ""
  }
}
