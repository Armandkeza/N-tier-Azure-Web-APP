resource "random_password" "pass" {
  length = 20
}

resource "azurerm_postgresql_flexible_server" "webapp-db" {
  name                   = "webapp-db-server"
   resource_group_name = azurerm_resource_group.Webapp.name
   location            = azurerm_resource_group.Webapp.location
  version                = "13"
  delegated_subnet_id    = azurerm_subnet.postgrel_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.webapp_dns_zone.id
  administrator_login    = "adminpsql"
  administrator_password = random_password.pass.result
  high_availability {
    mode = "ZoneRedundant"
  }
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  backup_retention_days  = 7

  depends_on = [azurerm_private_dns_zone_virtual_network_link.private_dns_vnet_association]
}

