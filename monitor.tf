resource "azurerm_log_analytics_workspace" "monitor" {
  name                = local.log_analytics_workspace_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  tags                = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_log_analytics_solution" "ci" {
  solution_name         = "ContainerInsights"
  resource_group_name   = azurerm_log_analytics_workspace.monitor.resource_group_name
  location              = azurerm_log_analytics_workspace.monitor.location
  workspace_resource_id = azurerm_log_analytics_workspace.monitor.id
  workspace_name        = azurerm_log_analytics_workspace.monitor.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
  tags = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_application_insights" "ai" {
  name                = local.application_insights_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_log_analytics_workspace.monitor.location
  application_type    = "web"
  tags                = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "kv" {
  name                       = "diagnostic_setting_app"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.monitor.id

  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = true
      days    = local.retention_in_days
    }
  }
  log {
    category = "AzurePolicyEvaluationDetails"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = local.retention_in_days
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "web" {
  name                       = "diagnostic_setting_app"
  target_resource_id         = azurerm_app_service.web.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.monitor.id

  log {
    category = "AppServiceAuditLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = local.retention_in_days
    }
  }
  log {
    category = "AppServiceAppLogs"
    enabled  = false
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "AppServiceConsoleLogs"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "AppServiceHTTPLogs"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "AppServiceIPSecAuditLogs"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "AppServicePlatformLogs"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = local.retention_in_days
    }
  }

}

resource "azurerm_monitor_diagnostic_setting" "db" {
  name                       = "diagnostic_setting_app"
  target_resource_id         = azurerm_mssql_database.db.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.monitor.id

  log {
    category = "DevOpsOperationsAudit"
    enabled  = true

    retention_policy {
      enabled = true
      days    = local.retention_in_days
    }
  }
  log {
    category = "SQLSecurityAuditEvents"
    enabled  = true

    retention_policy {
      enabled = true
      days    = local.retention_in_days
    }
  }
  log {
    category = "AutomaticTuning"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "Blocks"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "DatabaseWaitStatistics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "Deadlocks"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "Errors"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "QueryStoreRuntimeStatistics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "QueryStoreWaitStatistics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SQLInsights"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "Timeouts"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "InstanceAndAppAdvanced"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  metric {
    category = "WorkloadManagement"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  metric {
    category = "Basic"
    enabled  = true

    retention_policy {
      enabled = true
      days    = local.retention_in_days
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "blob" {
  name = "diagnostic_setting_app"
  # See workaround details: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8275#issuecomment-755222989
  target_resource_id         = "${azurerm_storage_account.storage.id}/blobServices/default/"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.monitor.id

  log {
    category = "StorageRead"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }

  log {
    category = "StorageWrite"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
  log {
    category = "StorageDelete"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "Capacity"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  metric {
    category = "Transaction"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "agw" {
  name                       = "diagnostic_setting_app"
  target_resource_id         = azurerm_application_gateway.agw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.monitor.id
  log {
    category = "ApplicationGatewayAccessLog"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
  log {
    category = "ApplicationGatewayPerformanceLog"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
  log {
    category = "ApplicationGatewayFirewallLog"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "cosmosdb" {
  name                           = "diagnostic_setting_app"
  target_resource_id             = azurerm_cosmosdb_account.cosmosdb.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.monitor.id
  log_analytics_destination_type = "AzureDiagnostics"
  log {
    category = "DataPlaneRequests"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
  log {
    category = "MongoRequests"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
  log {
    category = "QueryRuntimeStatistics"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
  log {
    category = "PartitionKeyStatistics"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
  log {
    category = "PartitionKeyRUConsumption"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
  log {
    category = "ControlPlaneRequests"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
  log {
    category = "CassandraRequests"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
  log {
    category = "GremlinRequests"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
  log {
    category = "TableApiRequests"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
  metric {
    category = "Requests"
    enabled  = true
    retention_policy {
      days    = local.retention_in_days
      enabled = true
    }
  }
}

