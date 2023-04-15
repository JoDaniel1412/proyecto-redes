provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "dns" {
  name     = "${var.group}-dns"
  location = "eastus"
}

resource "azurerm_dns_zone" "example" {
  name                = "atlastf.com"
  resource_group_name = azurerm_resource_group.dns.name
}

resource "azurerm_dns_a_record" "example" {
  name                = "www"
  zone_name           = azurerm_dns_zone.example.name
  resource_group_name = azurerm_resource_group.dns.name
  ttl                 = 300
  records             = ["10.0.0.1"]
}
