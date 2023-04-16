
resource "azurerm_resource_group" "dns" {
  name     = "${var.group}-dns"
  location = "eastus"
}

resource "azurerm_dns_zone" "asimov" {
  name                = "asimov.io"
  resource_group_name = azurerm_resource_group.dns.name
}

resource "azurerm_dns_zone" "dostoievski" {
  name                = "dostoievski.io"
  resource_group_name = azurerm_resource_group.dns.name
}

# resource "azurerm_dns_zone" "google" {
#   name                = "google.com"
#   resource_group_name = azurerm_resource_group.dns.name
# }

resource "azurerm_dns_a_record" "asimov-site" {
  name                = "asimov-site"
  zone_name           = azurerm_dns_zone.asimov.name
  resource_group_name = azurerm_resource_group.dns.name
  ttl                 = 300
  records             = ["8.8.8.8", "8.8.8.9"]
}

resource "azurerm_dns_a_record" "dostoievski-site" {
  name                = "dostoievski-site"
  zone_name           = azurerm_dns_zone.dostoievski.name
  resource_group_name = azurerm_resource_group.dns.name
  ttl                 = 300
  records             = ["8.8.8.8", "8.8.8.9"]
}

# resource "azurerm_dns_a_record" "google-site" {
#   name                = "google-site"
#   zone_name           = azurerm_dns_zone.google.name
#   resource_group_name = azurerm_resource_group.dns.name
#   ttl                 = 300
#   records             = ["8.8.8.8", "8.8.8.9"]
# }
