resource "azurerm_resource_group" "RG-Linux" {
    name = "${local.name}-VM"
    location = var.VM-location
}