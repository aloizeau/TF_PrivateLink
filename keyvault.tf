resource "azurerm_key_vault" "kv" {
  tenant_id           = data.azurerm_client_config.current.tenant_id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  name                = local.key_vault_name

  sku_name = "standard"

  #soft_delete_retention_days = 7
  purge_protection_enabled = false

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.web.id]
    # The list of allowed ip addresses (Current agent DevOps Ip) + cf. https://docs.microsoft.com/en-us/azure/devops/organizations/security/allow-list-ip-url?view=azure-devops&tabs=IP-V4#inbound-connections
    ip_rules = [chomp(data.http.currentip.body), "40.74.28.0/23"]
  }
  tags = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_key_vault_access_policy" "current" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover", "Backup"]
}

resource "azurerm_key_vault_access_policy" "web" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = azurerm_app_service.web.identity[0].tenant_id
  object_id          = azurerm_app_service.web.identity[0].principal_id
  secret_permissions = ["Get", "List"]
}

resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "_%@$"
}

resource "azurerm_key_vault_secret" "sql" {
  name            = "SQL-ADMIN-PASSWORD"
  value           = random_password.admin_password.result
  key_vault_id    = azurerm_key_vault.kv.id
  tags            = local.tags
  content_type    = "text/plain"
  expiration_date = formatdate("YYYY-MM-DD'T'00:00:00Z", timeadd(timestamp(), "2160h")) #Today + 90Days

  depends_on = [
    azurerm_key_vault_access_policy.current
  ]

  lifecycle {
    ignore_changes = [
      expiration_date,
      tags
    ]
  }
}

resource "azurerm_key_vault_secret" "sql_connection_string" {
  name            = "SQL-CONNECTION-STRING"
  value           = "Server=tcp:${azurerm_mssql_server.server.name}.privatelink.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.db.name};Authentication=Active Directory Managed Identity;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"
  key_vault_id    = azurerm_key_vault.kv.id
  tags            = local.tags
  content_type    = "text/plain"
  expiration_date = formatdate("YYYY-MM-DD'T'00:00:00Z", timeadd(timestamp(), "43800h")) #Today + 5years

  depends_on = [
    azurerm_key_vault_access_policy.current
  ]

  lifecycle {
    ignore_changes = [
      expiration_date,
      tags
    ]
  }
}

resource "azurerm_key_vault_secret" "storage_connection_string" {
  name            = "STORAGE-CONNECTION-STRING"
  value           = replace(azurerm_storage_account.storage.primary_connection_string, "core.windows.net", azurerm_private_dns_zone.blob.name)
  key_vault_id    = azurerm_key_vault.kv.id
  tags            = local.tags
  content_type    = "text/plain"
  expiration_date = formatdate("YYYY-MM-DD'T'00:00:00Z", timeadd(timestamp(), "43800h")) #Today + 5years

  depends_on = [
    azurerm_key_vault_access_policy.current
  ]

  lifecycle {
    ignore_changes = [
      expiration_date,
      tags
    ]
  }
}
