# ---------- Create Azure OpenAI ----------
resource azurerm_cognitive_account openai {
  name                = "openai"
  location            = var.rg.location
  resource_group_name = var.rg.name
  kind                = "OpenAI"

  sku_name = "S0"
}

# ---------- Create App Service Plan, Storage account for Function App ----------
resource "azurerm_service_plan" "asp-openai" {
  name                = "asp-openai-oscommand"
  resource_group_name = var.rg.name
  location            = var.rg.location

  os_type  = "Linux"
  sku_name = "Y1"
}

resource "azurerm_storage_account" "st-openai" {
  name                     = "stopenai123"
  resource_group_name      = var.rg.name
  location                 = var.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# ---------- Create Function App ----------
resource "azurerm_linux_function_app" "func-openai_oscommand" {
  name                = "func-openai-oscommand"
  resource_group_name = var.rg.name
  location            = var.rg.location

  storage_account_name       = azurerm_storage_account.st-openai.name
  storage_account_access_key = azurerm_storage_account.st-openai.primary_access_key
  service_plan_id            = azurerm_service_plan.asp-openai.id

  site_config {
    ftps_state = "FtpsOnly"

    application_stack {
      python_version = "3.12"
    }

    cors {
      allowed_origins = ["*"]
      support_credentials = false
    }
  }
}

resource "azurerm_function_app_function" "func-openai_oscommand-func" {
  name            = "http_trigger1"
  function_app_id = azurerm_linux_function_app.func-openai_oscommand.id
  language        = "Python"
  test_data       = null
  config_json     = jsonencode(
    {
      bindings = [
        {
          authLevel = "FUNCTION"
          direction = "IN"
          name      = "req"
          route     = "http_trigger1"
          type      = "httpTrigger"
        },
        {
          direction = "OUT"
          name      = "$return"
          type      = "http"
        },
      ]
    }
  )
}

# ---------- Create logic app for RBAC function ----------
# resource "azurerm_logic_app_workflow" "logic-rbac" {
#   name                = "logic-rbac"
#   location            = var.rg.location
#   resource_group_name = var.rg.name
# }

# ---------- Create logic app for OS Command injection function ----------
# resource "azurerm_logic_app_workflow" "logic-oscommand" {
#   name                = "logic-oscommand"
#   location            = var.rg.location
#   resource_group_name = var.rg.name
# }