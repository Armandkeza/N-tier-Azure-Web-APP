resource "azurerm_resource_group" "Webapp" {
    name     = "rg-webapp"
    location = "Canadacentral"
}

resource "azurerm_virtual_network" "Webapp-Vnet" {
    name                = "Webapp-Vnet"
    location            = azurerm_resource_group.Webapp.location
    resource_group_name = azurerm_resource_group.Webapp.name
    address_space       = ["10.1.0.0/16"]

}

resource "azurerm_subnet" "Frontend" {
    name                 = "Frontend"
    resource_group_name  = azurerm_resource_group.Webapp.name
    virtual_network_name = azurerm_virtual_network.Webapp-Vnet.name
    address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_subnet" "Backend" {
    name                 = "Backend"
    resource_group_name  = azurerm_resource_group.Webapp.name
    virtual_network_name = azurerm_virtual_network.Webapp-Vnet.name
    address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "APG" {
    name                 = "APG"
    resource_group_name  = azurerm_resource_group.Webapp.name
    virtual_network_name = azurerm_virtual_network.Webapp-Vnet.name
    address_prefixes     = ["10.1.2.0/24"]
}

# Create a subnet for Azure Firewall
resource "azurerm_subnet" "azfw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.Webapp.name
  virtual_network_name = azurerm_virtual_network.Webapp-Vnet.name
  address_prefixes     = ["10.1.3.0/24"]
}

# Create subnet for azure Bastion

resource "azurerm_subnet" "Bastion_Subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.Webapp.name
  virtual_network_name = azurerm_virtual_network.Webapp-Vnet.name
  address_prefixes     = ["10.1.9.0/27"]
}
# Create a postgresql subnet
resource "azurerm_subnet" "postgrel_subnet" {
  name                 = "postgrel-subnet"
   resource_group_name  = azurerm_resource_group.Webapp.name
  virtual_network_name = azurerm_virtual_network.Webapp-Vnet.name
  address_prefixes     = ["10.1.10.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}


# Create a public IP address for Bastion
resource "azurerm_public_ip" "Bastion_ip" {
  name                = "Bastion_ip"
  location            = azurerm_resource_group.Webapp.location
  resource_group_name = azurerm_resource_group.Webapp.name
  allocation_method   = "Static"
  sku = "Standard"
}
# Create a public IP address for Azure Firewall
resource "azurerm_public_ip" "pip_azfw" {
  name                = "web-azfw"
  location            = azurerm_resource_group.Webapp.location
  resource_group_name = azurerm_resource_group.Webapp.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
# Create a NAT gateway
#resource "azurerm_nat_gateway" "NATGW" {
  #name                = "NATGW"
  #location            = azurerm_resource_group.Webapp.location
  #resource_group_name = azurerm_resource_group.Webapp.name
  
  
#}
#resource "azurerm_nat_gateway_public_ip_association" "Webapp" {
 # nat_gateway_id       = azurerm_nat_gateway.NATGW.id
  #public_ip_address_id = azurerm_public_ip.natgw_ip.id
#}

#Associate NAT gatewat with Frontend Subnet
#resource "azurerm_subnet_nat_gateway_association" "Webapp-Nat" {
  #subnet_id      = azurerm_subnet.Frontend.id
  #nat_gateway_id = azurerm_nat_gateway.NATGW.id
#}

#Associate NAT gatewat with Backend Subnet
#resource "azurerm_subnet_nat_gateway_association" "Backend-Nat" {
 # subnet_id      = azurerm_subnet.Backend.id
  #nat_gateway_id = azurerm_nat_gateway.NATGW.id
#}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "APG-nsg" {
    name                = "APG-nsg"
    location            = azurerm_resource_group.Webapp.location
    resource_group_name = azurerm_resource_group.Webapp.name

    security_rule {
        name                       = "HTTP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    
     security_rule {
        name                       = "APG"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    tags = {
        environment = "onprem"
    }
}

resource "azurerm_subnet_network_security_group_association" "APG-nsg-association" {
    subnet_id                 = azurerm_subnet.APG.id
    network_security_group_id = azurerm_network_security_group.APG-nsg.id
}

resource "azurerm_route_table" "Firewall-route-table" {
  depends_on                    = [azurerm_subnet.azfw_subnet]
  name                          = "Firewall-route-table"
  location            = azurerm_resource_group.Webapp.location
  resource_group_name = azurerm_resource_group.Webapp.name
  disable_bgp_route_propagation = false
  route {
    name                   = "Firewall-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }
}
resource "azurerm_subnet_route_table_association" "Frontend-route-table" {
  subnet_id      = azurerm_subnet.Frontend.id
  route_table_id = azurerm_route_table.Firewall-route-table.id
}

resource "azurerm_subnet_route_table_association" "Backend-route-table" {
  subnet_id      = azurerm_subnet.Backend.id
  route_table_id = azurerm_route_table.Firewall-route-table.id
}