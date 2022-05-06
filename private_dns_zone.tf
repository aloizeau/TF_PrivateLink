resource "azurerm_private_dns_zone" "web" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rg_network.name
  tags                = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
resource "azurerm_private_dns_zone" "db" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg_network.name
  tags                = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg_network.name
  tags                = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
resource "azurerm_private_dns_zone" "cosmosdb" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.rg_network.name
  tags                = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
resource "azurerm_private_dns_zone" "vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg_network.name
  tags                = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}