terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.69.0"
    }
  }
}

provider "azurerm" {
  # tenant_id       = "c677eb29-07c2-4499-851f-86fb7a0a0fa3"
  # subscription_id = "59ba054a-1288-414d-a4a1-b87d3032f8b4"
  # client_id       = "1eb11f24-9c46-442e-963a-2dc0c96d3f43"
  # client_secret   = "1q58Q~emzoduZe5da~ZQ3Svof._GbmNXUspCEaco"
  features {}
}

resource "azurerm_resource_group" "firstRG" {
  name = "RG02"
  location = "Central India"
}

resource "azurerm_storage_account" "mystorage" {
  name                     = "storage14082023"
  resource_group_name      = azurerm_resource_group.firstRG.name
  location                 = azurerm_resource_group.firstRG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "mycontainer" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.mystorage.name
  container_access_type = "private"
}

# resource "azurerm_storage_blob" "myblob" {
#   name                   = "myindex"
#   storage_account_name   = azurerm_storage_account.mystorage.name
#   storage_container_name = azurerm_storage_container.mycontainer.name
#   type                   = "Block"
#   source                 = "index.html"
# }

# resource "azurerm_storage_blob" "myblob2" {
#   name                   = "myindex2"
#   storage_account_name   = azurerm_storage_account.mystorage.name
#   storage_container_name = azurerm_storage_container.mycontainer.name
#   type                   = "Block"
#   source                 = "index.html"
# }
