# Onboarding Windows Azure Arc
data "azurerm_arc_machine" "WIN-SVR02" {
  name                = "WIN-SVR02"
  resource_group_name = var.rg.name
}

resource "azurerm_arc_machine_extension" "WIN-SVR02-ext" {
  name           = "WIN-SVR02-ext"
  location       = var.rg.location
  arc_machine_id = data.azurerm_arc_machine.WIN-SVR02.id
  publisher      = "Microsoft.Azure.Monitor"
  type           = "AzureMonitorWindowsAgent"
}

# Create data collection rule
resource "azurerm_monitor_data_collection_rule" "dcr-win" {
  name                = "dcr-win"
  resource_group_name = var.rg.name
  location            = var.rg.location
  kind                = "Windows"

  destinations {
    log_analytics {
      workspace_resource_id = var.log_id
      name                  = "windows-destination-log"
    }
  }

  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = ["windows-destination-log"]
  }

  data_sources {
    windows_event_log {
      streams        = ["Microsoft-Event"]
      x_path_queries = ["ForwardedEvents!*[System[(EventID=4768 or EventID=4769)]]"]
      name           = "windows-datasource-wineventlog"
    }
  }

  depends_on = [
    azurerm_log_analytics_workspace.log
  ]
}

# Create data collection rule association
resource "azurerm_monitor_data_collection_rule_association" "dcra-win" {
  name                    = "dcra-win"
  target_resource_id      = data.azurerm_arc_machine.WIN-SVR02.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr-win.id
}