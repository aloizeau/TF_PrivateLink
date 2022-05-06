resource "azurerm_app_service_plan" "plan" {
  name                = local.service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }

  tags = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_app_service" "web" {
  name                = local.web_app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id
  https_only          = true

  app_settings = {
    "KEY_VAULT_URI"                                   = replace(azurerm_key_vault.kv.vault_uri, "vault.azure.net", azurerm_private_dns_zone.vault.name)
    "APPINSIGHTS_INSTRUMENTATIONKEY"                  = azurerm_application_insights.ai.instrumentation_key
    "APPINSIGHTS_PROFILERFEATURE_VERSION"             = "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"             = "1.0.0"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"           = azurerm_application_insights.ai.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION"      = "~2"
    "DiagnosticServices_EXTENSION_VERSION"            = "~3"
    "InstrumentationEngine_EXTENSION_VERSION"         = "disabled"
    "SnapshotDebugger_EXTENSION_VERSION"              = "disabled"
    "WEBSITE_HTTPLOGGING_RETENTION_DAYS"              = local.retention_in_days
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "disabled"
    "XDT_MicrosoftApplicationInsights_Java"           = "1"
    "XDT_MicrosoftApplicationInsights_Mode"           = "recommended"
    "XDT_MicrosoftApplicationInsights_NodeJS"         = "1"
    "XDT_MicrosoftApplicationInsights_PreemptSdk"     = "disabled"
  }

  site_config {
    dotnet_framework_version  = "v6.0"
    min_tls_version           = 1.2
    ftps_state                = "FtpsOnly"
    use_32_bit_worker_process = false
    websockets_enabled        = true
    always_on                 = true
    vnet_route_all_enabled    = true
    http2_enabled             = true
  }

  identity {
    type = "SystemAssigned"
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 30
        retention_in_mb   = 100
      }
    }
  }
  tags = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "integration" {
  app_service_id = azurerm_app_service.web.id
  subnet_id      = azurerm_subnet.subnet.id
}
