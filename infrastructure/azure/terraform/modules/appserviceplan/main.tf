# ---------- Create App Service Plan for Function App ----------
resource "azurerm_service_plan" "asp" {
  name                = "asp"
  resource_group_name = var.rg.name
  location            = var.rg.location

  os_type  = "Linux"
  sku_name = "Y1"
}

# ---------- Create Storage account for Function App ----------
resource "azurerm_storage_account" "st-asp" {
  name                     = "stasp"
  resource_group_name      = var.rg.name
  location                 = var.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# ---------- Create Function App ----------
resource "azurerm_linux_function_app" "func-openai_oscommand" {
  name                = "func-openaioscommand"
  resource_group_name = var.rg.name
  location            = var.rg.location

  storage_account_name       = azurerm_storage_account.st-asp.name
  storage_account_access_key = azurerm_storage_account.st-asp.primary_access_key
  service_plan_id            = azurerm_service_plan.asp.id

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
  name            = "func-openaioscommand-func"
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