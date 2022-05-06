resource "azurerm_private_endpoint" "web" {
  name                = local.web_private_endpoint_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.web.id

  private_service_connection {
    name                           = join("-", ["privateserviceconnection", azurerm_app_service.web.name])
    private_connection_resource_id = azurerm_app_service.web.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = join("-", [azurerm_resource_group.rg.name, "web"])
    private_dns_zone_ids = [azurerm_private_dns_zone.web.id]
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

#private DNS Link
resource "azurerm_private_dns_zone_virtual_network_link" "web" {
  name                  = "${azurerm_app_service.web.name}-dnslink"
  resource_group_name   = azurerm_resource_group.rg_network.name
  private_dns_zone_name = azurerm_private_dns_zone.web.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = true
  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

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
