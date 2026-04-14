resource "azurerm_public_ip" "vm-nic-pip" {
  name                = "vm-nic-pip"
  resource_group_name = var.rg.name
  location            = var.rg.location
  
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vm-nic" {
  name                = "vm-nic"
  resource_group_name = var.rg.name
  location            = var.rg.location

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.snet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-nic-pip.id
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                = "vm"
  resource_group_name = var.rg.name
  location            = var.rg.location

  network_interface_ids = [azurerm_network_interface.vm-nic.id]
  vm_size = "Standard_B1s"
  zones   = []

  storage_image_reference {
    offer     = "0001-com-ubuntu-server-jammy"
    publisher = "canonical"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "stvm"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "vm"
    admin_username = "lab"
    admin_password = "6^T$PVw6RAvf"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}