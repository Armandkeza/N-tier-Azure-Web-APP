resource "azurerm_private_dns_zone" "webapp_dns_zone" {
  name                = "webapp.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.Webapp.name
}

# Create Private DNS Zone for storage account
resource "azurerm_private_dns_zone" "storage-dns-zone" {
  name                = "webapp.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.Webapp.name
}
resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_vnet_association" {
  name                  = "webapp-private_dns_vnet_association"
  private_dns_zone_name = azurerm_private_dns_zone.webapp_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.Webapp-Vnet.id
  resource_group_name   = azurerm_resource_group.Webapp.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_vnet_association_storage" {
  name                  = "webapp-private_dns_vnet_association"
  private_dns_zone_name = azurerm_private_dns_zone.storage-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.Webapp-Vnet.id
  resource_group_name   = azurerm_resource_group.Webapp.name
}