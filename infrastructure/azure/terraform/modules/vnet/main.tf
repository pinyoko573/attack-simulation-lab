resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  resource_group_name = var.rg.name
  location            = var.rg.location
  
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "vnet-snet" {
  name                 = "vnet-snet"
  resource_group_name  = var.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "vnet-snet-nsg-ssh_allow" {
  name                = "nsg-ssh_allow"
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

resource "azurerm_subnet_network_security_group_association" "vnet-snet-nsg-ssh_allow-association" {
  subnet_id                 = azurerm_subnet.vnet-snet.id
  network_security_group_id = azurerm_network_security_group.vnet-snet-nsg-ssh_allow.id
}