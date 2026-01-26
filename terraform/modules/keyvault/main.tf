resource "azurerm_key_vault" "kv" {
  name                = "kv"
  resource_group_name = var.rg.name
  location            = var.rg.location
  
  sku_name            = "standard"
  tenant_id           = var.sub_tenant_id

  network_acls {
    bypass         = "None"
    default_action = "Allow"
  }
}