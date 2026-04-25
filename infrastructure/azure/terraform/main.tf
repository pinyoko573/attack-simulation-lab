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

module "arc-linux" {
  source = "./modules/arc/linux"
  rg = {
    name     = azurerm_resource_group.rg-lab.name
    location = azurerm_resource_group.rg-lab.location
  }
  log = module.sentinel.log
}

module "vnet" {
  source = "./modules/vnet"
  rg = {
    name     = azurerm_resource_group.rg-lab.name
    location = azurerm_resource_group.rg-lab.location
  }
}

module "networkwatcher" {
  source = "./modules/networkwatcher"
  rg = {
    name     = azurerm_resource_group.rg-lab.name
    location = azurerm_resource_group.rg-lab.location
  }
  log = module.sentinel.log
  vnet_id = module.vnet.vnet_id
}

module "vm" {
  source = "./modules/vm"
  rg = {
    name     = azurerm_resource_group.rg-lab.name
    location = azurerm_resource_group.rg-lab.location
  }
  snet_id = module.vnet.snet_id
}

module "keyvault" {
  source = "./modules/keyvault"
  rg = {
    name     = azurerm_resource_group.rg-lab.name
    location = azurerm_resource_group.rg-lab.location
  }
  log = module.sentinel.log
  sub_tenant_id = data.azurerm_client_config.current.tenant_id
}

module "foundry" {
  source = "./modules/foundry"
  rg = {
    name     = azurerm_resource_group.rg-lab.name
    location = azurerm_resource_group.rg-lab.location
  }
}