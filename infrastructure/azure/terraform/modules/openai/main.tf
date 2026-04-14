# ---------- Create Azure OpenAI ----------
resource azurerm_cognitive_account openai {
  name                = "openai"
  location            = var.rg.location
  resource_group_name = var.rg.name
  kind                = "OpenAI"

  sku_name = "S0"
}