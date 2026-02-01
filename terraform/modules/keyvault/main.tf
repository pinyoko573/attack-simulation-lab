resource "azurerm_key_vault" "kv" {
  name                = "kv-secret"
  resource_group_name = var.rg.name
  location            = var.rg.location
  
  sku_name            = "standard"
  tenant_id           = var.sub_tenant_id

  network_acls {
    bypass         = "None"
    default_action = "Allow"
  }
}

resource "azurerm_monitor_diagnostic_setting" "kv-diagnostic" {
  name = "kv-secret-diagnostic"
  target_resource_id = azurerm_key_vault.kv.id
  log_analytics_workspace_id = var.log.id

  enabled_log {
    category_group       = "audit"
  }
}