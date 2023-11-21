resource "azurerm_firewall_policy" "azfw_policy" {
  name                     = "azfw-policy"
  location            = azurerm_resource_group.Webapp.location
  resource_group_name = azurerm_resource_group.Webapp.name
  sku                      = "Premium"
  threat_intelligence_mode = "Alert"
}

resource "azurerm_ip_group" "workload_ip_group" {
  name                = "workload-ip-group"
  location            = azurerm_resource_group.Webapp.location
  resource_group_name = azurerm_resource_group.Webapp.name
  cidrs               = ["10.1.0.0/24", "10.1.1.0/24"]
}

resource "azurerm_firewall_policy_rule_collection_group" "net_policy_rule_collection_group" {
  name               = "DefaultNetworkRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.azfw_policy.id
  priority           = 200
  network_rule_collection {
    name     = "DefaultNetworkRuleCollection"
    action   = "Allow"
    priority = 200
    rule {
      name                  = "DNS"
      protocols             = ["UDP","TCP"]
      source_ip_groups      = [azurerm_ip_group.workload_ip_group.id]
      destination_ports     = ["53"]
      destination_addresses = ["0.0.0.0/0"]
    }
  }
}
resource "azurerm_firewall_policy_rule_collection_group" "app_policy_rule_collection_group" {
  name               = "DefaulApplicationtRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.azfw_policy.id
  priority           = 300
  application_rule_collection {
    name     = "WebCategoriesRule"
    action   = "Deny"
    priority = 400
    rule {
      name = "Block defined URL categories"

      description = "Block know URL categories"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups      = [azurerm_ip_group.workload_ip_group.id]
      web_categories = [
            "ChildAbuseImages",
            "Gambling",
            "HateAndIntolerance",
            "IllegalDrug",
            "IllegalSoftware",
            "Nudity",
            "pornographyandsexuallyexplicit", # does not work
            "Violence",
            "Weapons"
        ]
    }
  }
  application_rule_collection {
    name     = "Allow Web traffic"
    action   = "Allow"
    priority = 500
    rule {
      name        = "Global Rule"
      description = "Allow Internet Access"
      
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      destination_fqdns = ["*"]
      terminate_tls     = false
      source_ip_groups  = [azurerm_ip_group.workload_ip_group.id]
    }
  }
}

resource "azurerm_firewall" "fw" {
  name                = "azfw"
  location            = azurerm_resource_group.Webapp.location
  resource_group_name = azurerm_resource_group.Webapp.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  ip_configuration {
    name                 = "azfw-ipconfig"
    subnet_id            = azurerm_subnet.azfw_subnet.id
    public_ip_address_id = azurerm_public_ip.pip_azfw.id
  }
  firewall_policy_id = azurerm_firewall_policy.azfw_policy.id
}