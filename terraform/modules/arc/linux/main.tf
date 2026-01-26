# Onboarding Linux Azure Arc
data "azurerm_arc_machine" "ubuntu-svr01" {
  name                = "ubuntu-svr01"
  resource_group_name = var.rg.name
}

resource "azurerm_arc_machine_extension" "ubuntu-svr01-ext" {
  name           = "ubuntu-svr01-ext"
  location       = var.rg.location
  arc_machine_id = data.azurerm_arc_machine.ubuntu-svr01.id
  publisher      = "Microsoft.Azure.Monitor"
  type           = "AzureMonitorLinuxAgent"
}

# Create data collection rule
resource "azurerm_monitor_data_collection_rule" "dcr-linux" {
  name                = "dcr-linux"
  resource_group_name = var.rg.name
  location            = var.rg.location
  kind                = "Linux"

  destinations {
    log_analytics {
      workspace_resource_id = var.log_id
      name                  = "linux-destination-log"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["linux-destination-log"]
  }

  data_sources {
    syslog {
      facility_names = ["auth"]
      log_levels     = ["Info"]
      name           = "linux-datasource-syslog"
      streams        = ["Microsoft-Syslog"]
    }
  }

  depends_on = [
    azurerm_log_analytics_workspace.log
  ]
}

# Create data collection rule association
resource "azurerm_monitor_data_collection_rule_association" "dcra-linux" {
  name                    = "dcra-linux"
  target_resource_id      = data.azurerm_arc_machine.ubuntu-svr01.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr-linux.id
}