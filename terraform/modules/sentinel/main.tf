# ---------- Create log analytics workspace ----------
resource "azurerm_log_analytics_workspace" "log" {
  name                = "log"
  resource_group_name = var.rg.name
  location            = var.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ---------- Onboard to Sentinel ----------
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "log_sentinel" {
  workspace_id                 = azurerm_log_analytics_workspace.log.id
  customer_managed_key_enabled = false
}