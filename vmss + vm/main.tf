# # terraform {
# #   required_providers {
# #     azurerm = {
# #       source  = "hashicorp/azurerm"
# #       version = "3.69.0"
# #     }
# #   }
# # }

# # provider "azurerm" {
# #   features {}
# # }


# resource "azurerm_resource_group" "RG" {
#   name     = "FIRSTRG"
#   location = "Central India"
# }

# resource "azurerm_virtual_network" "VNET" {
#   name                = "FIRSTVNET"
#   resource_group_name = azurerm_resource_group.RG.name
#   location            = azurerm_resource_group.RG.location
#   address_space       = ["10.0.0.0/16"]
# }

# resource "azurerm_subnet" "SUBNET" {
#   name                 = "PRIVATESUBNET"
#   resource_group_name  = azurerm_resource_group.RG.name
#   virtual_network_name = azurerm_virtual_network.VNET.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

# resource "azurerm_subnet" "SUBNET1" {
#   name                 = "PUBLICSUBNET"
#   resource_group_name  = azurerm_resource_group.RG.name
#   virtual_network_name = azurerm_virtual_network.VNET.name
#   address_prefixes     = ["10.0.2.0/24"]

# }

# resource "azurerm_windows_virtual_machine_scale_set" "WVMSS" {
#   name                = "WINDVMSS"
#   resource_group_name = azurerm_resource_group.RG.name
#   location            = azurerm_resource_group.RG.location
#   sku                 = "Standard_F2"
#   instances           = 2
#   admin_username      = "admin123"
#   admin_password      = "M@r10@135"

#   network_interface {
#     name    = "nic1"
#     primary = "true"

#     ip_configuration {
#       name      = "firstnic"
#       primary   = "true"
#       subnet_id = azurerm_subnet.SUBNET.id


#     }

#   }

#   os_disk {
#     storage_account_type = "Standard_LRS"
#     caching              = "ReadWrite"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2016-Datacenter-Server-Core"
#     version   = "latest"
#   }

#   zones = [2]

# }

# resource "azurerm_network_security_group" "NSG" {
#   name                = "NSGPRIVATE"
#   resource_group_name = azurerm_resource_group.RG.name
#   location            = azurerm_resource_group.RG.location

#   security_rule {
#     name                       = "RDP"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "3389"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "HTTP"
#     priority                   = 110
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "80"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

# }

# resource "azurerm_subnet_network_security_group_association" "NSGASSOCIATE" {
#   subnet_id                 = azurerm_subnet.SUBNET.id
#   network_security_group_id = azurerm_network_security_group.NSG.id

# }

# # resource "azurerm_public_ip" "PUBLICIP" {
# #     name = "PUBLICIPADDRESS"
# #     resource_group_name = azurerm_resource_group.RG.name
# #     location = azurerm_resource_group.RG.location
# #     allocation_method = "Static"

# # }

# resource "azurerm_resource_group" "PUBLICRG" {
#   name     = "PUBLICRB01"
#   location = "East US"

# }

# resource "azurerm_virtual_network" "PUBLICVNET" {
#   name                = "PUBLICVNET02"
#   resource_group_name = azurerm_resource_group.PUBLICRG.name
#   location            = "East US"
#   address_space       = ["20.0.0.0/16"]

# }

# resource "azurerm_subnet" "PUBLICSUBNET" {
#   name                 = "PUBLICSUBNET01"
#   resource_group_name  = azurerm_resource_group.PUBLICRG.name
#   virtual_network_name = azurerm_virtual_network.PUBLICVNET.name
#   address_prefixes     = ["20.0.1.0/24"]

# }

# resource "azurerm_network_security_group" "PUBLICNSG" {
#   name                = "PUBLICNSG01"
#   resource_group_name = azurerm_resource_group.PUBLICRG.name
#   location            = "East US"

#   security_rule {
#     name                       = "Allow-HTTP"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

# #     security_rule {
# #     name                       = "Allow-RDP"
# #     priority                   = 110
# #     direction                  = "Inbound"
# #     access                     = "Allow"
# #     protocol                   = "Tcp"
# #     source_port_range          = "3389"
# #     destination_port_range     = "3389"
# #     source_address_prefix      = "*"
# #     destination_address_prefix = "*"
# #   }

# }

# resource "azurerm_subnet_network_security_group_association" "SUBNETASSOCIATEPUBLICNSG" {
#   subnet_id                 = azurerm_subnet.PUBLICSUBNET.id
#   network_security_group_id = azurerm_network_security_group.PUBLICNSG.id

# }

# resource "azurerm_windows_virtual_machine_scale_set" "PUBLICWMSS" {
#   name                = "PUBLICVMS"
#   resource_group_name = azurerm_resource_group.PUBLICRG.name
#   location            = "East US"
#   sku                 = "Standard_F2"
#   instances           = 1
#   #zones = [2]
#   network_interface {
#     name    = "PUBLICNIC"
#     primary = "true"

#     ip_configuration {
#       name      = "PUBLICNIC01"
#       subnet_id = azurerm_subnet.PUBLICSUBNET.id
#       primary   = "true"
#       #  public_ip_address {
#       #    name = "PUBLICIP"
#       #   public_ip_prefix_id = azurerm_public_ip_prefix.PUBLICIPPREFIX.id
#       # #   #public_ip_address = azurerm_public_ip.PUBLICIP.id
#       #  }
#     }
#   }
#   os_disk {

#     storage_account_type = "Standard_LRS"
#     caching              = "ReadWrite"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2016-Datacenter-Server-Core"
#     version   = "latest"
#   }

#   data_disk {
#     # name = "DISK1"
#     disk_size_gb         = "5"
#     storage_account_type = "Standard_LRS"
#     caching              = "ReadWrite"
#     lun                  = 1
#   }

#   admin_username = "admin123"
#   admin_password = "M@r10@135"
# }

# # resource "azurerm_public_ip_prefix" "PUBLICIPPREFIX" {
# #   name                = "PublicIpPrefix1"
# #   location            = azurerm_resource_group.PUBLICRG.location
# #   resource_group_name = azurerm_resource_group.PUBLICRG.name

# #   prefix_length = 31

# # #   #tags = {
# # #     environment = "Production"
# # #   }
# # }

# resource "azurerm_public_ip" "PUBLICIP1" {
#   name                = "Publicip1"
#   resource_group_name = azurerm_resource_group.PUBLICRG.name
#   location            = azurerm_resource_group.PUBLICRG.location
#   allocation_method   = "Static"
# }

# resource "azurerm_network_interface" "NICPUBLIC" {
#   name                = "PUBLICNIC1"
#   resource_group_name = azurerm_resource_group.PUBLICRG.name
#   location            = azurerm_resource_group.PUBLICRG.location
#   ip_configuration {
#     name                 = "PUBLICNIC01"
#     subnet_id            = azurerm_subnet.PUBLICSUBNET.id
#     private_ip_address_allocation = "Dynamic"
#     #allocation_method    = "Dynamic"
#     public_ip_address_id = azurerm_public_ip.PUBLICIP1.id
#   }

# }

# resource "azurerm_subnet_network_security_group_association" "PUBLICNICASSOCIATION" {
#   subnet_id                 = azurerm_subnet.PUBLICSUBNET.id
#   network_security_group_id = azurerm_network_security_group.PUBLICNSG.id

# }

# resource "azurerm_windows_virtual_machine" "WINDOWSVM" {
#   name                  = "newVM01"
#   resource_group_name   = azurerm_resource_group.PUBLICRG.name
#   location              = azurerm_resource_group.PUBLICRG.location
#   network_interface_ids = [azurerm_network_interface.NICPUBLIC.id]
#   size                  = "Standard_B1s"
#   admin_username        = "admin123"
#   admin_password        = "M@r10@135"

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2019-Datacenter"
#     version   = "latest"
#   }

# }


