resource "azurerm_storage_account" "storage" {
  name                      = local.storage_account_name
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_account_network_rules" "rules" {
  storage_account_id         = azurerm_storage_account.storage.id
  default_action             = "Deny"
  ip_rules                   = [chomp(data.http.currentip.body)]
  bypass                     = ["Logging", "Metrics", "AzureServices"]
  virtual_network_subnet_ids = [azurerm_subnet.web.id]
  private_link_access {
    endpoint_resource_id = azurerm_private_endpoint.storage.id
    endpoint_tenant_id   = data.azurerm_subscription.current.tenant_id
  }
}

resource "azurerm_storage_container" "container" {
  name                  = "images"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "image" {
  name                   = "logo.png"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "./images/logo.png"
}

# Not permit with my personal user account
resource "azurerm_role_assignment" "web" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_app_service.web.identity.0.principal_id
}
