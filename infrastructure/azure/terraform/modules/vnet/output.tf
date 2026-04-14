output vnet_id {
  value = azurerm_virtual_network.vnet.id
}

output vnet-snet_id {
  value = azurerm_subnet.vnet-snet.id
}