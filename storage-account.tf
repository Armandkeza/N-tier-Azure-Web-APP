resource "azurerm_storage_account" "webapp-storage" {
  name                     = "ndayikeza135"
  location            = azurerm_resource_group.Webapp.location
  resource_group_name = azurerm_resource_group.Webapp.name
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "ZRS"
  public_network_access_enabled = "false"
 
}

resource "azurerm_storage_container" "webapp-container" {
  name                  = "webappmedia"
  storage_account_name  = azurerm_storage_account.webapp-storage.name
  container_access_type = "private"
}

# Create Private Endpint
resource "azurerm_private_endpoint" "webapp-endpoint" {
  name                = "webapp-storage-endpoint"
  location            = azurerm_resource_group.Webapp.location
  resource_group_name = azurerm_resource_group.Webapp.name
  subnet_id           = azurerm_subnet.Frontend.id
  private_service_connection {
    name                           = "webapp-storage-endpoint"
    private_connection_resource_id = azurerm_storage_account.webapp-storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

# Create DNS A Record
resource "azurerm_private_dns_a_record" "dns_a" {
  name                = "webapp-fronend"
  zone_name           = azurerm_private_dns_zone.storage-dns-zone.name
  resource_group_name = azurerm_resource_group.Webapp.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.webapp-endpoint.private_service_connection.0.private_ip_address]
}