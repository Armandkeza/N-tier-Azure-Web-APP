
# Create a Public IP for the APG
resource "azurerm_public_ip" "Webapp-PIP" {
  name                = "Webapp-PIP"
  resource_group_name = azurerm_resource_group.Webapp.name
  location            = azurerm_resource_group.Webapp.location
  allocation_method   = "Static"
  sku = "Standard"
}
# Create an Azure Application Gateway
resource "azurerm_application_gateway" "Webapp-APG" {
  name                = "Webapp-APG"
  resource_group_name = azurerm_resource_group.Webapp.name
  location            = azurerm_resource_group.Webapp.location
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  
  }
   zones      = ["1","2"]
  firewall_policy_id = azurerm_web_application_firewall_policy.webapp-waf.id

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.APG.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.Webapp-PIP.id
  }

   backend_address_pool {
    name = "my-backend-pool"
    
  }

   backend_http_settings {
    name                  = "my-backend-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                  = "my-https-listener"
    frontend_ip_configuration_name = "PublicIPAddress"
    frontend_port_name     = "http"
    protocol              = "Http"
  }

  request_routing_rule {
    name                       = "my-routing-rule"
    rule_type                  = "Basic"
    http_listener_name           = "my-https-listener"
    backend_address_pool_name    = "my-backend-pool"
    backend_http_settings_name   = "my-backend-http-settings"
    priority = 1
  }



}
  



