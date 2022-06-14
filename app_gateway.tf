resource "azurerm_user_assigned_identity" "agw" {
  name                = local.agw_user_name
  location            = azurerm_resource_group.rg_network.location
  resource_group_name = azurerm_resource_group.rg_network.name

  tags = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_public_ip" "agw" {
  name                = local.agw_ip_name
  location            = azurerm_resource_group.rg_network.location
  resource_group_name = azurerm_resource_group.rg_network.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_application_gateway" "agw" {
  name                = local.agw_name
  location            = azurerm_resource_group.rg_network.location
  resource_group_name = azurerm_resource_group.rg_network.name
  enable_http2        = true
  tags                = local.tags

  sku {
    #Sku with WAF is : WAF_v2
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw.id]
  }

  gateway_ip_configuration {
    name      = "agw-ip-configuration"
    subnet_id = azurerm_subnet.agw_subnet.id
  }

  frontend_ip_configuration {
    name                 = "agw-ip-configuration-public"
    public_ip_address_id = azurerm_public_ip.agw.id
  }

  frontend_port {
    name = "80"
    port = 80
  }

  frontend_port {
    name = "443"
    port = 443
  }

  backend_address_pool {
    name  = azurerm_app_service.web.name
    fqdns = [azurerm_app_service.web.default_site_hostname]
  }

  ssl_certificate {
    name                = azurerm_key_vault_certificate.agw.name
    key_vault_secret_id = azurerm_key_vault_certificate.agw.secret_id
  }

  backend_http_settings {
    name                  = azurerm_app_service.web.name
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    host_name             = azurerm_app_service.web.default_site_hostname
    request_timeout       = 1
  }

  http_listener {
    name                           = "http"
    frontend_ip_configuration_name = "agw-ip-configuration-public"
    frontend_port_name             = "80"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "https"
    frontend_ip_configuration_name = "agw-ip-configuration-public"
    frontend_port_name             = "443"
    protocol                       = "Https"
    ssl_certificate_name           = azurerm_key_vault_certificate.agw.name
  }

  request_routing_rule {
    name                       = "https"
    rule_type                  = "Basic"
    http_listener_name         = "https"
    backend_address_pool_name  = azurerm_app_service.web.name
    backend_http_settings_name = azurerm_app_service.web.name
  }

  redirect_configuration {
    name                 = "Redirect"
    redirect_type        = "Permanent"
    include_path         = true
    include_query_string = true
    target_listener_name = "https"
  }

  request_routing_rule {
    name                        = "http"
    rule_type                   = "Basic"
    http_listener_name          = "http"
    redirect_configuration_name = "Redirect"
  }

  // Ignore most changes as they will be managed manually
  lifecycle {
    ignore_changes = [
      tags,
      backend_address_pool,
      backend_http_settings,
      frontend_port,
      http_listener,
      probe,
      request_routing_rule,
      url_path_map,
      ssl_certificate,
      redirect_configuration,
      autoscale_configuration
    ]
  }

  depends_on = [
    azurerm_user_assigned_identity.agw,
    azurerm_key_vault_access_policy.agw,
    azurerm_key_vault_certificate.agw,
    time_sleep.wait_60_seconds
  ]
}
