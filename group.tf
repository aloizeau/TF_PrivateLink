resource "azurerm_resource_group" "rg" {
  name     = local.rg_app_name
  location = local.location
  tags     = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_resource_group" "rg_network" {
  name     = local.rg_network_name
  location = local.location
  tags     = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

