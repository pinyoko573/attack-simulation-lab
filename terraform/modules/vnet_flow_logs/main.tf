# Create network watcher
resource "azurerm_network_watcher" "nw" {
    name                = "nw"
    resource_group_name = var.rg.name
    location            = var.rg.location
}

# Create storage for network watcher flow logs
resource "azurerm_storage_account" "st-flowlog" {
  name                = "stflowlog"
  resource_group_name = var.rg.name
  location            = var.rg.location

  account_kind             = "Storage"
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

# Create network watcher flow logs
resource "azurerm_network_watcher_flow_log" "nw-flowlog" {
  name                = "nw-flowlog"
  resource_group_name = var.rg.name

  version              = 2
  network_watcher_name = azurerm_network_watcher.nw.name
  storage_account_id   = azurerm_storage_account.st.id
  target_resource_id   = var.vnet_id
  enabled              = true

  retention_policy {
    days    = 0
    enabled = false
  }

  traffic_analytics {
    enabled               = true
    interval_in_minutes   = 10
    workspace_id          = var.log.workspace_id
    workspace_region      = var.rg.location
    workspace_resource_id = var.log.id
  }
}