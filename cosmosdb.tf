resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                              = local.cosmosdb_name
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = azurerm_resource_group.rg.location
  offer_type                        = "Standard"
  kind                              = "GlobalDocumentDB"
  is_virtual_network_filter_enabled = true
  ip_range_filter                   = chomp(data.http.currentip.body)
  virtual_network_rule {
    id = azurerm_subnet.subnet.id
  }
  virtual_network_rule {
    id = azurerm_subnet.web.id
  }
  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = "northeurope"
    failover_priority = 1
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_cosmosdb_sql_database" "sql" {
  name                = local.cosmosdb_sql_db_name
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "container" {
  name                = "container"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  database_name       = azurerm_cosmosdb_sql_database.sql.name
  partition_key_path  = "/id"
}

resource "azurerm_role_assignment" "CosmosDB" {
  scope                = azurerm_cosmosdb_account.cosmosdb.id
  role_definition_name = "DocumentDB Account Contributor"
  principal_id         = azurerm_app_service.web.identity.0.principal_id
}
