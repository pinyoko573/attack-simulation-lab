# ---------- Create Microsoft Foundry ----------
resource "azurerm_ai_foundry" "aif" {
  name                = "aif"
  location            = var.rg.location
  resource_group_name = var.rg.name
  storage_account_id  = ""
  key_vault_id        = ""

  identity {
    type = "SystemAssigned"
  }
}

# ---------- Create Microsoft Foundry Project ----------
resource "azurerm_ai_foundry_project" "aif-proj" {
  name               = "aif-proj"
  location           = azurerm_ai_foundry.aif.location
  ai_services_hub_id = azurerm_ai_foundry.aif.id
}