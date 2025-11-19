terraform { 
  required_providers { 
    azurerm = { source = "hashicorp/azurerm", version = "~>3.0" } 
    random  = { source = "hashicorp/random", version = "~>3.6" } 
  } 
  required_version = ">=1.4" 

  # ✅ Backend for storing Terraform state in Azure Storage. 
  # The resource group + storage account + container are created 
  # by the GitHub Actions bootstrap job, not by Terraform. 
  backend "azurerm" { 
    resource_group_name  = "tfstate-rg-df" 
    storage_account_name = "tfstate2025df" 
    container_name       = "tfstate" 
    key                  = "lesson6.terraform.tfstate" 
  } 
} 

provider "azurerm" { 
  features {
  } 
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

# ❌ REMOVED: tfstate_rg, tfstate storage account, and container. 
# Those are created by the bootstrap job in the GitHub Actions workflow, 
# so Terraform should not try to create them again. 
# ✅ ONLY app resource group and app resources are managed by Terraform 
resource "azurerm_resource_group" "rg" { 
  name     = "lesson6-rg-df" 
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
