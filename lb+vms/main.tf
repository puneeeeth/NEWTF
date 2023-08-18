terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.69.0"
    }
  }
}

provider "azurerm" {
  features { }
}

resource "azurerm_resource_group" "newrg" {
  name     = "newRG01"
  location = "Central India"
}

resource "azurerm_virtual_network" "newvnet" {
  name                = "newVNET01"
  resource_group_name = azurerm_resource_group.newrg.name
  location            = azurerm_resource_group.newrg.location
  address_space       = ["20.0.0.0/16"]
}

resource "azurerm_subnet" "mysubnet" {
  name                = "inside"
  resource_group_name = azurerm_resource_group.newrg.name
  #location = azurerm_resource_group.newrg.location
  virtual_network_name = azurerm_virtual_network.newvnet.name
  address_prefixes     = ["20.0.1.0/24"]
}

resource "azurerm_network_security_group" "mynsg" {
  name                = "newNSG01"
  resource_group_name = azurerm_resource_group.newrg.name
  location            = azurerm_resource_group.newrg.location

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "mynsgassociation" {
  subnet_id                 = azurerm_subnet.mysubnet.id
  network_security_group_id = azurerm_network_security_group.mynsg.id
}

resource "azurerm_managed_disk" "mydisk" {
  name                 = "myDISK01"
  resource_group_name  = azurerm_resource_group.newrg.name
  location             = azurerm_resource_group.newrg.location
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "5"
}

resource "azurerm_network_interface" "mynic" {
  name                = "myNIC01"
  resource_group_name = azurerm_resource_group.newrg.name
  location            = azurerm_resource_group.newrg.location

  ip_configuration {
    name                          = "newIP-VM01"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mypublic.id
  }

}

resource "azurerm_public_ip" "mypublic" {
  name                = "myPUBLIC01"
  resource_group_name = azurerm_resource_group.newrg.name
  location            = azurerm_resource_group.newrg.location
  allocation_method   = "Static"

}

resource "azurerm_network_interface" "mynic02" {
  name                = "myNIC02"
  resource_group_name = azurerm_resource_group.newrg.name
  location            = azurerm_resource_group.newrg.location

  ip_configuration {
    name                          = "newIP-VM02"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mypublic02.id
  }

}

resource "azurerm_public_ip" "mypublic02" {
  name                = "myPUBLIC02"
  resource_group_name = azurerm_resource_group.newrg.name
  location            = azurerm_resource_group.newrg.location
  allocation_method   = "Static"

}

resource "azurerm_windows_virtual_machine" "myvm01" {
  name                  = "newVM01"
  resource_group_name   = azurerm_resource_group.newrg.name
  location              = azurerm_resource_group.newrg.location
  network_interface_ids = [azurerm_network_interface.mynic.id]
  size                  = "Standard_B1s"
  admin_username        = "admin123"
  admin_password        = "M@r10@135"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

}

resource "azurerm_windows_virtual_machine" "myvm02" {
  name                  = "newVM02"
  resource_group_name   = azurerm_resource_group.newrg.name
  location              = azurerm_resource_group.newrg.location
  network_interface_ids = [azurerm_network_interface.mynic02.id]
  size                  = "Standard_B1s"
  admin_username        = "admin123"
  admin_password        = "M@r10@135"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

}

# Create LOAD BALANCER FOR THE ABOVE VM'S

resource "azurerm_public_ip" "publicipforlb" {
  name                = "IPFORLOADBALANCER"
  resource_group_name = azurerm_resource_group.newrg.name
  location            = azurerm_resource_group.newrg.location
  allocation_method   = "Static"
  sku = "Standard"
}

resource "azurerm_lb" "newlb" {
  name                = "NEWLB01"
  resource_group_name = azurerm_resource_group.newrg.name
  location            = azurerm_resource_group.newrg.location
  frontend_ip_configuration {
    name                 = "IPforLBfrontend"
    public_ip_address_id = azurerm_public_ip.publicipforlb.id
  }

  depends_on = [ azurerm_public_ip.publicipforlb ]
  sku = "Standard"

}

resource "azurerm_lb_backend_address_pool" "addresspool" {
  name            = "BackendAddressPool"
  loadbalancer_id = azurerm_lb.newlb.id

  depends_on = [ azurerm_lb.newlb ]
}

resource "azurerm_lb_backend_address_pool_address" "vm01_address" {
  name = "VM01"
  #loadbalancer_id = data.azurerm_lb.newlb.id
  backend_address_pool_id             = azurerm_lb_backend_address_pool.addresspool.id
  virtual_network_id = azurerm_virtual_network.newvnet.id
  #backend_address_ip_configuration_id = azurerm_network_interface.mynic.id
  ip_address = azurerm_network_interface.mynic.private_ip_address

  depends_on = [ azurerm_lb_backend_address_pool.addresspool ]

}

resource "azurerm_lb_backend_address_pool_address" "vm02_address" {
  name = "VM02"
  #loadbalancer_id = data.azurerm_lb.newlb.id
  backend_address_pool_id             = azurerm_lb_backend_address_pool.addresspool.id
  virtual_network_id = azurerm_virtual_network.newvnet.id
  #backend_address_ip_configuration_id = azurerm_network_interface.mynic.id
  ip_address = azurerm_network_interface.mynic02.private_ip_address

  depends_on = [ azurerm_lb_backend_address_pool.addresspool ]

}

resource "azurerm_lb_probe" "Probe1" {
    name = "FirstProbe"
    loadbalancer_id = azurerm_lb.newlb.id
    port = "22"
  
}

resource "azurerm_lb_rule" "Rule1" {
    name = "Rule1Priority"
    loadbalancer_id = azurerm_lb.newlb.id
    #resource_group_name = azurerm_resource_group.newrg.name
    protocol = "Tcp"
    frontend_port = 80
    backend_port = 80
    frontend_ip_configuration_name = "IPforLBfrontend"
    backend_address_pool_ids = [azurerm_lb_backend_address_pool.addresspool.id]
    #probe = azurerm_lb_probe.Probe1
  
}