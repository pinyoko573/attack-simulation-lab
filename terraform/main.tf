provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg-lab" {
  name     = "rg-lab"
  location = "southeastasia"
}

module "sentinel" {
  source = "./modules/sentinel"
  rg = {
    name     = azurerm_resource_group.rg-lab.name
    location = azurerm_resource_group.rg-lab.location
  }
}

# module "arc_win" {
#   source = "./modules/arc/win"
#   rg = {
#     name     = azurerm_resource_group.rg-lab.name
#     location = azurerm_resource_group.rg-lab.location
#   }
#   log_id = module.sentinel.log.id
# }

# module "arc_linux" {
#   source = "./modules/arc/linux"
#   rg = {
#     name     = azurerm_resource_group.rg-lab.name
#     location = azurerm_resource_group.rg-lab.location
#   }
#   log_id = module.sentinel.log.id
# }

# module "vm" {
#   source = "./modules/vm"
#   rg = {
#     name     = azurerm_resource_group.rg-lab.name
#     location = azurerm_resource_group.rg-lab.location
#   }
# }

# module "sentinel_vnet_flow_logs" {
#   source = "./modules/vnet_flow_logs"
#   rg = {
#     name     = azurerm_resource_group.rg-lab.name
#     location = azurerm_resource_group.rg-lab.location
#   }
#   log = module.sentinel.log
#   vnet_id = module.vm.vnet_id
# }

module "keyvault" {
  source = "./modules/keyvault"
  rg = {
    name     = azurerm_resource_group.rg-lab.name
    location = azurerm_resource_group.rg-lab.location
  }
  log = module.sentinel.log
  sub_tenant_id = data.azurerm_client_config.current.tenant_id
}