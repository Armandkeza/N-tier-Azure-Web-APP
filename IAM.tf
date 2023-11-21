data azurerm_subscription "current" { }

resource "azurerm_role_definition" "Frontend-storage" {
  name        = "StorageContainerReadWrite"
 # scope       = azurerm_storage_container.webapp-container.id
  scope = data.azurerm_subscription.current.id
  description = "Role for read and write access to a storage container"
  permissions{
      actions = [
        "Microsoft.Storage/storageAccounts/blobServices/containers/read",
        "Microsoft.Storage/storageAccounts/blobServices/containers/write",
      ]
    }
  assignable_scopes = [
   # azurerm_storage_container.webapp-container.id,
   data.azurerm_subscription.current.id,
  ]
}

# Create a user-defined managed identity
resource "azurerm_user_assigned_identity" "Frontend-identity" {
  name                = "Frontend-identity"
  resource_group_name = azurerm_resource_group.Webapp.name
 location            = azurerm_resource_group.Webapp.location
}

# Create a role assignment for the managed identity
resource "azurerm_role_assignment" "storagerole-assignment" {
  principal_id        = azurerm_user_assigned_identity.Frontend-identity.principal_id
  role_definition_name = azurerm_role_definition.Frontend-storage.name
  scope               = data.azurerm_subscription.current.id
}