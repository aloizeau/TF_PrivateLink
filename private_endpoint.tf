# See here to find the good sub-resource name:
# https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
resource "azurerm_private_endpoint" "storage" {
  name                = local.storage_private_endpoint_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.web.id

  private_service_connection {
    name                           = join("-", ["privateserviceconnection", azurerm_storage_account.storage.name])
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = join("-", [azurerm_resource_group.rg.name, "storage"])
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_private_endpoint" "sql" {
  name                = local.sql_private_endpoint_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.web.id

  private_service_connection {
    name                           = join("-", ["privateserviceconnection", azurerm_mssql_server.server.name])
    private_connection_resource_id = azurerm_mssql_server.server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = join("-", [azurerm_resource_group.rg.name, "sql"])
    private_dns_zone_ids = [azurerm_private_dns_zone.db.id]
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_private_endpoint" "key_vault" {
  name                = local.key_vault_private_endpoint_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.web.id

  private_service_connection {
    name                           = join("-", ["privateserviceconnection", azurerm_key_vault.kv.name])
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["Vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = join("-", [azurerm_resource_group.rg.name, "vault"])
    private_dns_zone_ids = [azurerm_private_dns_zone.vault.id]
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_private_endpoint" "cosmosdb" {
  name                = local.cosmosdb_private_endpoint_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.web.id

  private_service_connection {
    name                           = join("-", ["privateserviceconnection", azurerm_cosmosdb_account.cosmosdb.name])
    private_connection_resource_id = azurerm_cosmosdb_account.cosmosdb.id
    subresource_names              = ["SQL"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = join("-", [azurerm_resource_group.rg.name, "cosmosdb"])
    private_dns_zone_ids = [azurerm_private_dns_zone.cosmosdb.id]
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

