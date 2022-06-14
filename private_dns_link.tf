#private DNS Link blob Storage
resource "azurerm_private_dns_zone_virtual_network_link" "storage-network" {
  name                  = "${azurerm_storage_account.storage.name}-dnslink-vnet"
  resource_group_name   = azurerm_resource_group.rg_network.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage-web" {
  name                  = "${azurerm_storage_account.storage.name}-dnslink-web"
  resource_group_name   = azurerm_resource_group.rg_network.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.web.id
  registration_enabled  = false
  tags                  = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

#private DNS Link SQL
resource "azurerm_private_dns_zone_virtual_network_link" "sql-network" {
  name                  = "${azurerm_mssql_server.server.name}-dnslink-vnet"
  resource_group_name   = azurerm_resource_group.rg_network.name
  private_dns_zone_name = azurerm_private_dns_zone.db.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql-web" {
  name                  = "${azurerm_mssql_server.server.name}-dnslink-web"
  resource_group_name   = azurerm_resource_group.rg_network.name
  private_dns_zone_name = azurerm_private_dns_zone.db.name
  virtual_network_id    = azurerm_virtual_network.web.id
  registration_enabled  = false
  tags                  = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

#private DNS Link Key Vault
resource "azurerm_private_dns_zone_virtual_network_link" "kv-network" {
  name                  = "${azurerm_key_vault.kv.name}-dnslink-vnet"
  resource_group_name   = azurerm_resource_group.rg_network.name
  private_dns_zone_name = azurerm_private_dns_zone.vault.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv-web" {
  name                  = "${azurerm_key_vault.kv.name}-dnslink-web"
  resource_group_name   = azurerm_resource_group.rg_network.name
  private_dns_zone_name = azurerm_private_dns_zone.vault.name
  virtual_network_id    = azurerm_virtual_network.web.id
  registration_enabled  = false
  tags                  = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

#private DNS Link CosmosDB
resource "azurerm_private_dns_zone_virtual_network_link" "cosmosdb-network" {
  name                  = "${azurerm_cosmosdb_account.cosmosdb.name}-dnslink-vnet"
  resource_group_name   = azurerm_resource_group.rg_network.name
  private_dns_zone_name = azurerm_private_dns_zone.cosmosdb.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "cosmosdb-web" {
  name                  = "${azurerm_cosmosdb_account.cosmosdb.name}-dnslink-web"
  resource_group_name   = azurerm_resource_group.rg_network.name
  private_dns_zone_name = azurerm_private_dns_zone.cosmosdb.name
  virtual_network_id    = azurerm_virtual_network.web.id
  registration_enabled  = false
  tags                  = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}