locals {
  app_code          = "pocprivatelink"
  location          = "westeurope"
  retention_in_days = "30"
  rg_network_name   = "pocprivatelink-network"
  rg_app_name       = "pocprivatelink"

  #env_prefix                     = var.environment == "development" ? "dev" : var.environment == "integration" ? "int" : var.environment == "qualification" ? "qual" : var.environment == "pre-production" ? "pre-prod" : var.environment == "production" ? "" : "unknow"
  loc_prefix                      = azurerm_resource_group.rg.location == "westeurope" ? "ew" : azurerm_resource_group.rg.location == "northeurope" ? "en" : "u"
  agw_user_name                   = join("-", [var.environment, local.loc_prefix, "agwuser", local.app_code])
  agw_ip_name                     = join("-", [var.environment, local.loc_prefix, "agwip", local.app_code])
  agw_name                        = join("-", [var.environment, local.loc_prefix, "agw", local.app_code])
  agw_vnet_name                   = join("-", [var.environment, local.loc_prefix, "agw-vnet", local.app_code])
  agw_subnet_name                 = join("-", [var.environment, local.loc_prefix, "agw-subnet", local.app_code])
  cosmosdb_name                   = join("", [var.environment, local.loc_prefix, "cosmosdb"])
  cosmosdb_sql_db_name            = join("", [var.environment, local.loc_prefix, "cosmosdb", "sql"])
  key_vault_agw_name              = join("-", [var.environment, local.loc_prefix, "agwkv", "privatelink"])
  key_vault_name                  = join("-", [var.environment, local.loc_prefix, "kv", local.app_code])
  log_analytics_workspace_name    = join("-", [var.environment, local.loc_prefix, "log", local.app_code])
  application_insights_name       = join("-", [var.environment, local.loc_prefix, "ai", local.app_code])
  sql_server_name                 = join("-", [var.environment, local.loc_prefix, "sql", local.app_code])
  storage_account_name            = join("", [var.environment, local.loc_prefix, "storage", local.app_code])
  service_plan_name               = join("-", [var.environment, local.loc_prefix, "sp", local.app_code])
  web_app_name                    = join("-", [var.environment, local.loc_prefix, "web", local.app_code])
  vnet_name                       = join("-", [var.environment, local.loc_prefix, "vnet", local.app_code])
  subnet_name                     = join("-", [var.environment, local.loc_prefix, "subnet", local.app_code])
  vnet_web_name                   = join("-", [var.environment, local.loc_prefix, "vnet-web", local.app_code])
  subnet_web_name                 = join("-", [var.environment, local.loc_prefix, "subnet-web", local.app_code])
  web_private_endpoint_name       = join("-", [var.environment, local.loc_prefix, "private-endpoint", local.app_code, "web"])
  storage_private_endpoint_name   = join("-", [var.environment, local.loc_prefix, "private-endpoint", local.app_code, "storage"])
  sql_private_endpoint_name       = join("-", [var.environment, local.loc_prefix, "private-endpoint", local.app_code, "sql"])
  cosmosdb_private_endpoint_name  = join("-", [var.environment, local.loc_prefix, "private-endpoint", local.app_code, "cosmosdb"])
  key_vault_private_endpoint_name = join("-", [var.environment, local.loc_prefix, "private-endpoint", local.app_code, "kv"])
  sql_server_storage              = join("", [var.environment, local.loc_prefix, "storage", "sql", local.app_code])
  tags = {
    environment = var.environment,
    createdBy   = "terraform",
    appCode     = local.app_code
  }
}
