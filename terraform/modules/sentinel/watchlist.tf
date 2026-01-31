resource "azurerm_sentinel_watchlist" "log_watchlist-azure_app_ids" {
  name                       = "azure_app_ids"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.log_sentinel.workspace_id
  display_name               = "azure_app_ids"
  item_search_key            = "appId"
}

# placeholder to allow provisioning for log_rule-successful_actions_performed_on_azure_resource_by_sp
resource "azurerm_sentinel_watchlist_item" "log_watchlist_item-azure_app_ids" {
  watchlist_id = azurerm_sentinel_watchlist.log_watchlist-azure_app_ids.id
  properties = {
    id = "00000000-0000-0000-0000-000000000000"
    appId = "00000000-0000-0000-0000-000000000000"
    appDisplayName = ""
  }
}