resource "azurerm_sentinel_watchlist" "log_watchlist-azure_app_ids" {
  name                       = "azure_app_ids"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.log_sentinel.workspace_id
  display_name               = "azure_app_ids"
  item_search_key            = "appId"
}