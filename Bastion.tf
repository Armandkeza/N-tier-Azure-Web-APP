resource "azurerm_bastion_host" "webapp-Bastion" {
  name                = "webapp-Bastion"
  location            = azurerm_resource_group.Webapp.location
  resource_group_name = azurerm_resource_group.Webapp.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.Bastion_Subnet.id
    public_ip_address_id = azurerm_public_ip.Bastion_ip.id
  }
}