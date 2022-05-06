locals {
  app_code          = "pocprivatelink"
  location          = "westeurope"
  retention_in_days = 30
  rg_network_name   = "z-afa-pocprivatelink-network-alu-sba-ew1-rgp01"
  rg_app_name       = "z-afa-pocprivatelink-alu-sba-ew1-rgp01"

  #env_prefix                     = var.environment == "development" ? "dev" : var.environment == "integration" ? "int" : var.environment == "qualification" ? "qual" : var.environment == "pre-production" ? "pre-prod" : var.environment == "production" ? "" : "unknow"
  loc_prefix                      = azurerm_resource_group.rg.location == "westeurope" ? "ew1" : azurerm_resource_group.rg.location == "northeurope" ? "en1" : "u"
  key_vault_name                  = join("", [var.environment, local.loc_prefix, "kv", local.app_code])
  log_analytics_workspace_name    = join("", [var.environment, local.loc_prefix, "log", local.app_code])
  application_insights_name       = join("", [var.environment, local.loc_prefix, "ai", local.app_code])
  sql_server_name                 = join("", [var.environment, local.loc_prefix, local.app_code, "sqlaz01"])
  storage_account_name            = join("", [var.environment, local.loc_prefix, "storage", "ppl", "sa01"])
  service_plan_name               = join("", ["z-afa-", local.app_code, "-s1-", var.environment, "-", local.loc_prefix, "psp01"])
  web_app_name                    = join("", [local.app_code, "-", var.environment, "-", local.loc_prefix, "01"])
  vnet_name                       = join("-", [var.environment, local.loc_prefix, "vnet", local.app_code, "vnet01"])
  subnet_name                     = join("-", [var.environment, local.loc_prefix, "subnet", local.app_code, "vnet01"])
  vnet_web_name                   = join("-", [var.environment, local.loc_prefix, "vnet-web", local.app_code, "vnet01"])
  subnet_web_name                 = join("-", [var.environment, local.loc_prefix, "subnet-web", local.app_code, "vnet01"])
  web_private_endpoint_name       = join("-", [var.environment, local.loc_prefix, "private-endpoint", local.app_code, "web"])
  storage_private_endpoint_name   = join("-", [var.environment, local.loc_prefix, "private-endpoint", local.app_code, "storage"])
  sql_private_endpoint_name       = join("-", [var.environment, local.loc_prefix, "private-endpoint", local.app_code, "sql"])
  key_vault_private_endpoint_name = join("-", [var.environment, local.loc_prefix, "private-endpoint", local.app_code, "kv"])
  sql_server_storage              = join("", [var.environment, local.loc_prefix, "storage", "ppl", "sa02"])
  tags = {
    environment          = var.environment,   
    businessServiceSilva = "AFA SOCLE CLOUD AZURE@1463",
    dsi_tribe            = "DTECH_SOCLES_TRANS",
    opco                 = "AFA",
    cloudPermit          = "dacloud"
  }
}
