variable "dns_ttl" {
  type        = number
  default     = 3600
  description = "Time To Live (TTL) of the DNS record (in seconds)."
}

resource "azurerm_dns_zone" "asimov" {
  name                = "www.asimov.io"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_dns_zone" "dostoievski" {
  name                = "www.dostoievski.io"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_dns_zone" "google" {
  name                = "www.google.com"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_dns_a_record" "asimov-record" {
  name                = "www"
  resource_group_name = azurerm_resource_group.main.name
  zone_name           = azurerm_dns_zone.asimov.name
  ttl                 = var.dns_ttl
  records             = [azurerm_public_ip.pip.ip_address]
}

resource "azurerm_dns_a_record" "dostoievski-record" {
  name                = "www"
  resource_group_name = azurerm_resource_group.main.name
  zone_name           = azurerm_dns_zone.dostoievski.name
  ttl                 = var.dns_ttl
  records             = [azurerm_public_ip.pip.ip_address]
}

resource "azurerm_dns_a_record" "google-record" {
  name                = "www"
  resource_group_name = azurerm_resource_group.main.name
  zone_name           = azurerm_dns_zone.dostoievski.name
  ttl                 = var.dns_ttl
  records             = [azurerm_public_ip.pip.ip_address]
}
