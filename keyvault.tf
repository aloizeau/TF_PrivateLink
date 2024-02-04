resource "azurerm_key_vault" "kv" {
  tenant_id           = data.azurerm_client_config.current.tenant_id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  name                = local.key_vault_name

  sku_name = "standard"

  #soft_delete_retention_days = 7
  purge_protection_enabled = false

  network_acls {
    bypass                     = "None"
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.web.id, azurerm_subnet.subnet.id]
    # The list of allowed ip addresses (Current agent DevOps Ip) + cf. https://docs.microsoft.com/en-us/azure/devops/organizations/security/allow-list-ip-url?view=azure-devops&tabs=IP-V4#inbound-connections
    ip_rules = [chomp(data.http.currentip.body)]
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
  key_permissions    = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey"]
}

resource "azurerm_key_vault_access_policy" "web" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = azurerm_app_service.web.identity[0].tenant_id
  object_id          = azurerm_app_service.web.identity[0].principal_id
  secret_permissions = ["Get", "List"]
  key_permissions    = ["Get", "List"]
}

resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "_%@$"
}

resource "azurerm_key_vault_key" "sql" {
  name         = "SQL-ADMIN-PASSWORD"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  tags = local.tags
  lifecycle {
    ignore_changes = [
      expiration_date,
      tags
    ]
  }
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
  value           = "Server=tcp:${azurerm_mssql_server.server.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.db.name};Authentication=Active Directory Managed Identity;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"
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
  value           = azurerm_storage_account.storage.primary_connection_string
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

resource "azurerm_key_vault_secret" "cosmosdb_connection_string" {
  name            = "COSMOSDB-CONNECTION-STRING"
  value           = join("", ["AccountEndpoint=", azurerm_cosmosdb_account.cosmosdb.endpoint, ";AccountKey=", azurerm_cosmosdb_account.cosmosdb.primary_key, ";"])
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
resource "azurerm_key_vault_secret" "cosmosdb_sql_name" {
  name            = "COSMOSDB-SQL-NAME"
  value           = azurerm_cosmosdb_sql_database.sql.name
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

resource "azurerm_key_vault_secret" "cosmosdb_container_name" {
  name            = "COSMOSDB-CONTAINER-NAME"
  value           = azurerm_cosmosdb_sql_container.container.name
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

resource "azurerm_key_vault" "agw" {
  tenant_id           = data.azurerm_client_config.current.tenant_id
  location            = azurerm_resource_group.rg_network.location
  resource_group_name = azurerm_resource_group.rg_network.name
  name                = local.key_vault_agw_name

  sku_name = "standard"

  #soft_delete_retention_days = 7
  purge_protection_enabled = false

  tags = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_key_vault_access_policy" "agw_current" {
  key_vault_id            = azurerm_key_vault.agw.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azurerm_client_config.current.object_id
  secret_permissions      = ["Get", "List", "Set", "Delete", "Purge", "Recover", "Backup"]
  certificate_permissions = ["Create", "Get", "List"]
}

resource "azurerm_key_vault_access_policy" "agw" {
  key_vault_id            = azurerm_key_vault.agw.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = azurerm_user_assigned_identity.agw.principal_id
  secret_permissions      = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
  key_permissions         = ["Get", "List"]
}

resource "azurerm_key_vault_certificate" "agw" {
  name         = "agw"
  key_vault_id = azurerm_key_vault.agw.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = ["myappgateway.com"]
      }

      subject            = "CN=myappgateway.com"
      validity_in_months = 12
    }
  }
  depends_on = [
    azurerm_key_vault_access_policy.agw
  ]
}

resource "time_sleep" "wait_60_seconds" {
  depends_on      = [azurerm_key_vault_certificate.agw]
  create_duration = "60s"
}

