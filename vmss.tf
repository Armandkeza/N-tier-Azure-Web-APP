
resource "azurerm_linux_virtual_machine_scale_set" "Front-vmss" {
  depends_on                    = [azurerm_subnet.azfw_subnet]
  name                = "Front-vmss"
  resource_group_name = azurerm_resource_group.Webapp.name
  location            = azurerm_resource_group.Webapp.location
  sku                 = "Standard_F2"
  instances           = 2
  zones               = ["1","2"]
  admin_username      = "adminuser"
  admin_password       = "Admin1#$%^&*()"
  disable_password_authentication = false
  custom_data = filebase64("/cloud-init.txt")

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }


  network_interface {
    name    = "Frontend-Interface"
    primary = true
     ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.Frontend.id
      #application_gateway_backend_address_pool_ids = ["${azurerm_application_gateway.Webapp-APG.id}"]
      application_gateway_backend_address_pool_ids = ["${azurerm_application_gateway.Webapp-APG.id}/backendAddressPools/my-backend-pool"]
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.Frontend-identity.id]
  

  }
}



  resource "azurerm_linux_virtual_machine_scale_set" "Backend-vmss" {
  depends_on                    = [azurerm_subnet.azfw_subnet]
  name                = "Backend-vmss"
  resource_group_name = azurerm_resource_group.Webapp.name
  location            = azurerm_resource_group.Webapp.location
  sku                 = "Standard_F2"
  instances           = 2
  admin_username      = "adminuser"
  admin_password       = "Admin1#$%^&*()"
  disable_password_authentication = false
  custom_data = filebase64("/cloud-init.txt")

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "Backend-Interface"
    primary = true
     ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.Backend.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.backendpool.id]
      
    }
  }
  }
