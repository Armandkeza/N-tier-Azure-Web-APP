resource "azurerm_lb" "Backend" {
  name                = "Backend"
  resource_group_name = azurerm_resource_group.Webapp.name
  location            = azurerm_resource_group.Webapp.location
  sku                 = "Standard"
  
    frontend_ip_configuration {
    name                          = "backendlbip"
    subnet_id                     = azurerm_subnet.Backend.id
    private_ip_address_allocation =  "Dynamic"
  }
 
}

resource "azurerm_lb_backend_address_pool" "backendpool" {
  loadbalancer_id = azurerm_lb.Backend.id
  name            = "backendpool"
}



resource "azurerm_lb_probe" "backend" {
  loadbalancer_id = azurerm_lb.Backend.id
  name            = "http-probe"
  protocol        = "Http"
  request_path    = "/"
  port            = 80
}