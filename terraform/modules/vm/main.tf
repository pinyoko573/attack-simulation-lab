resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  resource_group_name = var.rg.name
  location            = var.rg.location
  
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "snet" {
  name                 = "snet"
  resource_group_name  = var.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "pip"
  resource_group_name = var.rg.name
  location            = var.rg.location
  
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "nic"
  resource_group_name = var.rg.name
  location            = var.rg.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_security_group" "nsg-sshallow" {
  name                = "nsg-sshallow"
  resource_group_name = var.rg.name
  location            = var.rg.location

  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nic-nsgallow" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg-sshallow.id
}

resource "azurerm_virtual_machine" "vm" {
  name                = "vm"
  resource_group_name = var.rg.name
  location            = var.rg.location

  network_interface_ids = [azurerm_network_interface.nic.id]
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